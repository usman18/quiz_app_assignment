from flask import Flask, jsonify
import os
import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv

# Load environment variables from a .env file (if present)
load_dotenv()

app = Flask(__name__)


def _clean_quiz_value(raw):
    """Normalize the quiz column value to a plain string.

    Handles cases where Postgres may return a composite/text representation
    that looks like a tuple string, for example: (1,"Quiz 1 - General Trivia")
    and converts it to the plain quiz name.
    """
    if raw is None:
        return None
    # If already a simple string without tuple-like markers, return as-is
    if not isinstance(raw, str):
        try:
            return str(raw)
        except Exception:
            return raw

    s = raw.strip()
    # Detect tuple-like string starting with '('
    if s.startswith('(') and ',' in s:
        # take substring after first comma
        try:
            part = s[s.find(',') + 1 :].strip()
            # strip enclosing parentheses if present
            if part.endswith(')'):
                part = part[:-1]
            # strip surrounding quotes (single or double)
            while (part.startswith('"') and part.endswith('"')) or (
                part.startswith("'") and part.endswith("'")
            ):
                part = part[1:-1]
            # dedupe repeated quote characters
            part = part.replace('"""', '"').replace("'''", "'")
            # unescape doubled quotes
            part = part.replace('""', '"').replace("''", "'")
            return part
        except Exception:
            return s
    # Otherwise return the original string
    return s


def get_db_connection():
    # Read DATABASE_URL from environment
    database_url = os.environ.get('DATABASE_URL')
    if not database_url:
        raise RuntimeError('DATABASE_URL environment variable is not set')

    # psycopg2 can accept the DATABASE_URL directly
    conn = psycopg2.connect(database_url)
    return conn


@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"


@app.route('/quizzes', methods=['GET'])
def list_quizzes():
    """Fetch all quizzes from public.quiz table and return as JSON list"""
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        cur.execute('SELECT id, quiz FROM public.quiz ORDER BY id;')
        rows = cur.fetchall()
        cur.close()
        conn.close()

        # Build simple plain dicts to avoid any duplicated keys or extra metadata
        quizzes = [
            {
                'id': r.get('id'),
                'quiz': _clean_quiz_value(r.get('quiz')),
            }
            for r in rows
        ]
        return jsonify({'quizzes': quizzes}), 200
    except Exception as e:
        app.logger.exception('Error fetching quizzes')
        return jsonify({'error': str(e)}), 500


@app.route('/quizzes/<int:quiz_id>/questions', methods=['GET'])
def get_quiz_questions(quiz_id):
    """Return questions for a given quiz id.

    Response: { "questions": [ { "id": 1, "question": "...", "answer": true }, ... ] }
    """
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        cur.execute(
            'SELECT id, question, answer FROM public.questions WHERE quiz_id = %s ORDER BY id;',
            (quiz_id,)
        )
        rows = cur.fetchall()
        cur.close()
        conn.close()

        questions = [
            {
                'id': r.get('id'),
                'question': r.get('question'),
                'answer': bool(r.get('answer')) if r.get('answer') is not None else None,
            }
            for r in rows
        ]
        return jsonify({'questions': questions}), 200
    except Exception as e:
        app.logger.exception('Error fetching questions for quiz %s', quiz_id)
        return jsonify({'error': str(e)}), 500


@app.route('/responses', methods=['POST'])
def submit_responses():
    """Store participant responses for a quiz.

    Expected JSON body:
    {
      "participant_id": "some-id-or-name",
      "quiz_id": 1,
      "answers": [ {"question_id": 1, "submitted_answer": true}, ... ]
    }

    Returns: { "inserted": [1,2,3], "count": 3 }
    """
    payload = None
    try:
        payload = (flask_request := __import__('flask').request).get_json()
    except Exception:
        return jsonify({'error': 'Invalid JSON payload'}), 400

    if not payload:
        return jsonify({'error': 'Empty request body'}), 400

    participant_id = payload.get('participant_id')
    quiz_id = payload.get('quiz_id')
    answers = payload.get('answers')

    if quiz_id is None or not isinstance(quiz_id, int):
        return jsonify({'error': 'quiz_id (integer) is required'}), 400
    if not isinstance(answers, list) or len(answers) == 0:
        return jsonify({'error': 'answers (non-empty list) is required'}), 400

    inserted_ids = []
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        # Use transaction - we'll commit after inserts
        for ans in answers:
            qid = ans.get('question_id')
            submitted = ans.get('submitted_answer')
            # allow None for submitted to represent unanswered, otherwise coerce to bool
            if qid is None:
                conn.rollback()
                return jsonify({'error': 'question_id missing in one of the answers'}), 400

            cur.execute(
                'INSERT INTO public.responses (participant_id, quiz_id, question_id, submitted_answer) VALUES (%s, %s, %s, %s) RETURNING id;',
                (participant_id, quiz_id, qid, submitted)
            )
            row = cur.fetchone()
            if row:
                inserted_ids.append(row[0])

        conn.commit()
        cur.close()
        conn.close()
        return jsonify({'inserted': inserted_ids, 'count': len(inserted_ids)}), 201
    except Exception as e:
        try:
            conn.rollback()
        except Exception:
            pass
        app.logger.exception('Error inserting responses')
        return jsonify({'error': str(e), 'payload': payload}), 500




if __name__ == '__main__':
    # If a .env file is used locally, developer can load it before running.
    # The app expects DATABASE_URL to be set in the environment.
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 10000)))
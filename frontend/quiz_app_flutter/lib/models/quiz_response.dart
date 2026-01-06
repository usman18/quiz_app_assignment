// To parse this JSON data, do
//
//     final quizResponse = quizResponseFromMap(jsonString);

import 'dart:convert';

QuizResponse quizResponseFromMap(String str) =>
    QuizResponse.fromMap(json.decode(str));

String quizResponseToMap(QuizResponse data) => json.encode(data.toMap());

class QuizResponse {
  String participantId;
  int quizId;
  List<Answer> answers;

  QuizResponse({
    required this.participantId,
    required this.quizId,
    required this.answers,
  });

  factory QuizResponse.fromMap(Map<String, dynamic> json) => QuizResponse(
    participantId: json["participant_id"],
    quizId: json["quiz_id"],
    answers: List<Answer>.from(json["answers"].map((x) => Answer.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "participant_id": participantId,
    "quiz_id": quizId,
    "answers": List<dynamic>.from(answers.map((x) => x.toMap())),
  };
}

class Answer {
  int questionId;
  bool submittedAnswer;

  Answer({required this.questionId, required this.submittedAnswer});

  factory Answer.fromMap(Map<String, dynamic> json) => Answer(
    questionId: json["question_id"],
    submittedAnswer: json["submitted_answer"],
  );

  Map<String, dynamic> toMap() => {
    "question_id": questionId,
    "submitted_answer": submittedAnswer,
  };
}

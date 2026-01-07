# Quiz App Project Specification

## Scope

- Quizzes contain only True/False questions
- Focus is on building features for users to browse quizzes, view questions, and submit their answers

## Assumptions

- The database is pre-populated with sample quizzes since an admin panel is not currently in scope
- All APIs are public (no authentication required) to support anonymous submissions. Users can submit multiple responses, with each stored as a separate database entry

## Implementation

### Frontend
**Flutter** is used to build the front end of the quiz app, providing users with an interface to browse available quizzes, select a specific quiz to view its questions, answer them, and submit their responses.

### Backend / Database
For this, APIs are written in backend in **Flask** application which is deployed over **Render** making the APIs accessible for the mobile app. **Neon DB** (PostgreSQL) is used as the database.

The application uses 3 APIs to fetch and persist data:

#### API Endpoints


#### 1. Get All Quizzes
```bash
curl http://localhost:5001/quizzes
```
Response:
```json
{
  "quizzes": [
    {"id": 1, "quiz": "Quiz 1 - General Trivia"},
    {"id": 2, "quiz": "Quiz 2 - Another Quiz"}
  ]
}
```

#### 2. Get Quiz Questions
```bash
curl http://localhost:5001/quizzes/1/questions
```
Response:
```json
{
  "questions": [
    {
      "id": 1,
      "question": "The Great Wall of China is the only man-made structure visible from space",
      "answer": true
    },
    {
      "id": 2,
      "question": "The planet Mars is often called the \"Red Planet\"",
      "answer": false
    },
    {
      "id": 3,
      "question": "A group of crows is called a \"murder\"",
      "answer": true
    }
  ]
}
```

#### 3. Submit Quiz Responses
```bash
curl -X POST http://localhost:5001/responses \
  -H "Content-Type: application/json" \
  -d '{
    "participant_id": "anon-123",
    "quiz_id": 1,
    "answers": [
      {"question_id": 1, "submitted_answer": true},
      {"question_id": 2, "submitted_answer": false}
    ]
  }'
```


### Db Schema:

#### Table: quiz

| column_name | data_type | character_maximum_length | is_nullable |
|-------------|-----------|--------------------------|-------------|
| id          | integer   |                          | NO          |
| name        | text      |                          | NO          |


#### Constraints: 

| constraint_name | constraint_type | column_name |
|-----------------|-----------------|-------------|
| quiz_pkey       | PRIMARY KEY     | id          |



#### Table: questions

| column_name | data_type | character_maximum_length | is_nullable |
|-------------|-----------|--------------------------|-------------|
| id          | integer   |                          | NO          |
| quiz_id     | integer   |                          | NO          |
| answer      | boolean   |                          | NO          |
| question    | text      |                          | NO          |


#### Constraints:

| constraint_name | constraint_type | column_name |
|-----------------|-----------------|-------------|
| questions_pkey  | PRIMARY KEY     | id          |
| fk_quiz_id      | FOREIGN KEY     | quiz_id     |



#### Table: responses

| column_name | data_type | character_maximum_length | is_nullable |
|-------------|-----------|--------------------------|-------------|
| id          | integer   |                          | NO          |
| quiz_id     | integer   |                          | NO          |
| answer      | boolean   |                          | NO          |
| question    | text      |                          | NO          |


#### Constraints:


| constraint_name          | constraint_type | column_name |
|--------------------------|-----------------|-------------|
| responses_pkey           | PRIMARY KEY     | id          |
| fk_responses_quiz_id     | FOREIGN KEY     | quiz_id     |
| fk_responses_question_id | FOREIGN KEY     | question_id |
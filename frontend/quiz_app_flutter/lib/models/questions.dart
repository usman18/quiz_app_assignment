// To parse this JSON data, do
//
//     final questions = questionsFromMap(jsonString);

import 'dart:convert';

Questions questionsFromMap(String str) => Questions.fromMap(json.decode(str));

String questionsToMap(Questions data) => json.encode(data.toMap());

class Questions {
  List<Question> questions;

  Questions({required this.questions});

  factory Questions.fromMap(Map<String, dynamic> json) => Questions(
    questions: List<Question>.from(
      json["questions"].map((x) => Question.fromMap(x)),
    ),
  );

  Map<String, dynamic> toMap() => {
    "questions": List<dynamic>.from(questions.map((x) => x.toMap())),
  };
}

class Question {
  bool answer;
  int id;
  String question;

  Question({required this.answer, required this.id, required this.question});

  factory Question.fromMap(Map<String, dynamic> json) => Question(
    answer: json["answer"],
    id: json["id"],
    question: json["question"],
  );

  Map<String, dynamic> toMap() => {
    "answer": answer,
    "id": id,
    "question": question,
  };
}

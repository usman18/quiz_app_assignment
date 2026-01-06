// To parse this JSON data, do
//
//     final quizzes = quizzesFromMap(jsonString);

import 'dart:convert';

Quizzes quizzesFromMap(String str) => Quizzes.fromMap(json.decode(str));

String quizzesToMap(Quizzes data) => json.encode(data.toMap());

class Quizzes {
  List<Quiz> quizzes;

  Quizzes({required this.quizzes});

  factory Quizzes.fromMap(Map<String, dynamic> json) => Quizzes(
    quizzes: List<Quiz>.from(json["quizzes"].map((x) => Quiz.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "quizzes": List<dynamic>.from(quizzes.map((x) => x.toMap())),
  };
}

class Quiz {
  int id;
  String quiz;

  Quiz({required this.id, required this.quiz});

  factory Quiz.fromMap(Map<String, dynamic> json) =>
      Quiz(id: json["id"], quiz: json["quiz"]);

  Map<String, dynamic> toMap() => {"id": id, "quiz": quiz};
}

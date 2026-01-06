import 'package:flutter/material.dart';

class QuizSubmittedScreen extends StatefulWidget {
  const QuizSubmittedScreen({super.key});

  @override
  State<QuizSubmittedScreen> createState() => _QuizSubmittedScreenState();
}

class _QuizSubmittedScreenState extends State<QuizSubmittedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Quiz Submitted Successfully')));
  }
}

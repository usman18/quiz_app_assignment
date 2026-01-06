import 'package:flutter/material.dart';
import 'package:quiz_app_flutter/screens/quiz_questions_screen.dart';

import '../network/api_client.dart';
import '../models/quizzes.dart';

class QuizzesScreen extends StatefulWidget {
  const QuizzesScreen({super.key});

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  late final Future<Quizzes> _quizzesFuture;
  List<Quiz> _quizzes = [];

  @override
  void initState() {
    super.initState();
    _quizzesFuture = ApiClient.instance.fetchQuizzes().then((q) {
      // populate local state for easier updates (refresh/navigation)
      if (mounted) {
        setState(() {
          _quizzes = q.quizzes;
        });
      }
      return q;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select A Quiz'), centerTitle: true),
      body: FutureBuilder<Quizzes>(
        future: _quizzesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final error = snapshot.error;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading quizzes: $error',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // use local state copy of quizzes so the list can be
          // updated independently of the FutureBuilder snapshot
          if (_quizzes.isEmpty) {
            return const Center(child: Text('No quizzes available'));
          }

          return ListView.separated(
            itemCount: _quizzes.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final quiz = _quizzes[index];
              return ListTile(
                title: Text(quiz.quiz),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          QuizQuestionsScreen(quizId: quiz.id),
                    ),
                  );
                },
                trailing: Icon(Icons.forward),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:quiz_app_flutter/widgets/quiz_question_widget.dart';

import '../network/api_client.dart';
import '../models/questions.dart';
import '../models/quiz_response.dart';
import 'quiz_submitted_screen.dart';

class QuizQuestionsScreen extends StatefulWidget {
  final int quizId;

  const QuizQuestionsScreen({super.key, required this.quizId});

  @override
  State<QuizQuestionsScreen> createState() => _QuizQuestionsScreenState();
}

class _QuizQuestionsScreenState extends State<QuizQuestionsScreen> {
  late final Future<Questions> _questionsFuture;
  List<Question> _questions = [];
  final Map<int, bool> _selections = {}; // questionId -> selected answer
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _questionsFuture = ApiClient.instance
        .fetchQuizQuestions(widget.quizId)
        .then((q) {
          if (mounted) {
            setState(() {
              _questions = q.questions;
            });
          }
          return q;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Answer by selecting the option')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<Questions>(
              future: _questionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Error loading questions: ${snapshot.error}'),
                    ),
                  );
                }

                if (_questions.isEmpty) {
                  return const Center(child: Text('No questions available'));
                }

                return ListView.separated(
                  itemCount: _questions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final q = _questions[index];
                    return QuizQuestionWidget(
                      question: q,
                      onSelectionChanged: (value) {
                        // store selection by question id
                        _selections[q.id] = value;
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        // Ensure every question has a selection
                        final total = _questions.length;
                        final answered = _selections.length;
                        if (answered != total) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please answer all questions before submitting',
                              ),
                            ),
                          );
                          return;
                        }

                        // Build payload
                        final answers = _questions
                            .map(
                              (q) => Answer(
                                questionId: q.id,
                                submittedAnswer: _selections[q.id]!,
                              ),
                            )
                            .toList();

                        // create a unique participant id by appending timestamp
                        final participantId =
                            'anonymous-${DateTime.now().millisecondsSinceEpoch}';

                        final payload = QuizResponse(
                          participantId: participantId,
                          quizId: widget.quizId,
                          answers: answers,
                        );

                        setState(() {
                          _isSubmitting = true;
                        });

                        // show a SnackBar with loading indicator
                        final snackBarController = ScaffoldMessenger.of(context)
                            .showSnackBar(
                              const SnackBar(
                                duration: Duration(days: 1),
                                content: Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text('Submitting...'),
                                  ],
                                ),
                              ),
                            );

                        try {
                          final ok = await ApiClient.instance
                              .submitQuizResponse(payload);
                          // hide loading snackbar
                          snackBarController.close();

                          if (ok && mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const QuizSubmittedScreen(),
                              ),
                            );
                          }
                        } catch (e) {
                          snackBarController.close();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Submit failed: $e')),
                          );
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isSubmitting = false;
                            });
                          }
                        }
                      },
                child: const Text(
                  'Submit Answers',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

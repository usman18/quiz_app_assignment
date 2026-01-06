import 'package:flutter/material.dart';

import '../models/questions.dart';

/// Widget that renders a single [Question] and two buttons (True/False).
///
/// When a button is pressed, only that button is highlighted and the
/// `onSelectionChanged` callback is called with the boolean value.
class QuizQuestionWidget extends StatefulWidget {
  final Question question;
  final ValueChanged<bool> onSelectionChanged;

  const QuizQuestionWidget({
    super.key,
    required this.question,
    required this.onSelectionChanged,
  });

  @override
  State<QuizQuestionWidget> createState() => _QuizQuestionWidgetState();
}

class _QuizQuestionWidgetState extends State<QuizQuestionWidget> {
  bool? _selection; // true, false or null (none)

  void _select(bool value) {
    setState(() {
      _selection = value;
    });
    widget.onSelectionChanged(value);
  }

  ButtonStyle _buttonStyle(bool active) => ElevatedButton.styleFrom(
    backgroundColor: active ? Colors.blue : Colors.grey.shade200,
    foregroundColor: active ? Colors.white : Colors.black,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.question.question,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: _buttonStyle(_selection == true),
                  onPressed: () => _select(true),
                  child: const Text('True'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: _buttonStyle(_selection == false),
                  onPressed: () => _select(false),
                  child: const Text('False'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

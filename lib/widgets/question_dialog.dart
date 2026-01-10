import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question.dart';
import '../providers/game_notifier.dart';

class QuestionDialog extends ConsumerWidget {
  final Question question;
  const QuestionDialog({super.key, required this.question});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(blurRadius: 20, color: Colors.black)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "SORU",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 10),
          Text(question.text, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ...List.generate(
            question.options.length,
            (index) => Padding(
              padding: const EdgeInsets.all(4),
              child: ElevatedButton(
                onPressed: () =>
                    ref.read(gameProvider.notifier).answerQuestion(index),
                child: Text(question.options[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

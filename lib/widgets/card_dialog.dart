import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_card.dart';
import '../models/game_enums.dart';
import '../providers/game_notifier.dart';

class CardDialog extends ConsumerWidget {
  final GameCard card;
  const CardDialog({super.key, required this.card});

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
          Icon(
            card.type == CardType.sans ? Icons.star : Icons.bolt,
            size: 60,
            color: card.type == CardType.sans ? Colors.pink : Colors.teal,
          ),
          const SizedBox(height: 16),
          Text(
            card.type == CardType.sans ? "ŞANS KARTI" : "KADER KARTI",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 16),
          Text(
            card.description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.read(gameProvider.notifier).closeCardDialog(),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 45),
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            child: const Text("TAMAM"),
          ),
        ],
      ),
    );
  }
}

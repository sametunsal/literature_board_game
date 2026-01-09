import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/game_theme.dart';
import '../providers/game_notifier.dart';

class DiceRoller extends ConsumerWidget {
  const DiceRoller({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);

    // Zar atılıyor animasyonu
    if (state.isDiceRolled && state.diceTotal > 0) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: GameTheme.primaryText, width: 2),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.casino, size: 32, color: GameTheme.accentRed)
                .animate(onPlay: (c) => c.repeat())
                .shake(duration: 500.ms), // Sallanma efekti
            const SizedBox(width: 10),
            Text(
              "${state.diceTotal}",
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: GameTheme.primaryText,
              ),
            ).animate().scale(
              duration: 400.ms,
              curve: Curves.elasticOut,
            ), // Büyüme efekti
          ],
        ),
      );
    }

    // Normal Buton
    return ElevatedButton.icon(
          onPressed: () => ref.read(gameProvider.notifier).rollDice(),
          icon: const Icon(Icons.casino),
          label: const Text("ZAR AT"),
          style: ElevatedButton.styleFrom(
            backgroundColor: GameTheme.primaryText,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(
          delay: 2000.ms,
          duration: 1000.ms,
        ); // Kullanıcıyı dürtmek için parlama
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/game_constants.dart';
import '../../models/game_enums.dart';
import '../../providers/game_notifier.dart';

class KiraathaneDialog extends ConsumerStatefulWidget {
  const KiraathaneDialog({super.key});

  @override
  ConsumerState<KiraathaneDialog> createState() => _KiraathaneDialogState();
}

class _KiraathaneDialogState extends ConsumerState<KiraathaneDialog> {
  bool _choosingCategory = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);
    final player = state.currentPlayer;
    final canMesk = player.akce >= GameConstants.meskCostAkce;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _choosingCategory
                ? _buildCategoryChoice(canMesk)
                : _buildActionChoice(canMesk),
          ),
        ),
      ),
    );
  }

  Widget _buildActionChoice(bool canMesk) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTitle('Kıraathane'),
        const SizedBox(height: 16),
        _buildActionButton(
          icon: Icons.store_rounded,
          label: 'Alışveriş',
          onPressed: () {
            ref.read(gameProvider.notifier).openKiraathaneShop();
          },
        ),
        const SizedBox(height: 10),
        _buildActionButton(
          icon: Icons.school_rounded,
          label: 'Meşk (${GameConstants.meskCostAkce} Akçe)',
          onPressed: canMesk
              ? () => setState(() => _choosingCategory = true)
              : null,
        ),
        const SizedBox(height: 10),
        _buildActionButton(
          icon: Icons.close_rounded,
          label: 'Vazgeç',
          onPressed: () {
            ref.read(gameProvider.notifier).cancelKiraathane();
          },
          muted: true,
        ),
      ],
    );
  }

  Widget _buildCategoryChoice(bool canMesk) {
    final categories = QuestionCategory.values
        .where((category) => category != QuestionCategory.bonusBilgiler)
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTitle('Meşk Kategorisi'),
        const SizedBox(height: 12),
        ...categories.map(
          (category) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildActionButton(
              icon: Icons.menu_book_rounded,
              label: category.displayName,
              onPressed: canMesk
                  ? () {
                      ref.read(gameProvider.notifier).startMesk(category);
                    }
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 4),
        _buildActionButton(
          icon: Icons.arrow_back_rounded,
          label: 'Geri',
          onPressed: () => setState(() => _choosingCategory = false),
          muted: true,
        ),
      ],
    );
  }

  Widget _buildTitle(String title) {
    return Row(
      children: [
        const Icon(Icons.local_cafe_rounded, color: Colors.brown, size: 28),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool muted = false,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: muted ? Colors.grey.shade200 : Colors.brown.shade600,
        disabledBackgroundColor: Colors.grey.shade300,
        foregroundColor: muted ? Colors.black87 : Colors.white,
        disabledForegroundColor: Colors.grey.shade600,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/game_constants.dart';
import '../../models/game_enums.dart';
import '../../providers/game_notifier.dart';

class KiraathaneDialog extends ConsumerWidget {
  const KiraathaneDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    final player = state.currentPlayer;
    final canMesk = player.akce >= GameConstants.meskCostAkce;
    final screenSize = MediaQuery.sizeOf(context);
    // Landscape phones leave very little height — keep the dialog compact and
    // scroll the category list instead of overflowing.
    final isCompact = screenSize.height < 480;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: screenSize.height * 0.92,
        ),
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
            padding: EdgeInsets.all(isCompact ? 12 : 20),
            child: _buildCategoryChoice(ref, canMesk, isCompact),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChoice(WidgetRef ref, bool canMesk, bool isCompact) {
    final categories = QuestionCategory.values
        .where((category) => category != QuestionCategory.bonusBilgiler)
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTitle('Meşk Kategorisi', isCompact),
        SizedBox(height: isCompact ? 4 : 8),
        Text(
          '${GameConstants.meskCostAkce} Akçe',
          style: GoogleFonts.poppins(
            fontSize: isCompact ? 12 : 14,
            fontWeight: FontWeight.w600,
            color: Colors.brown.shade700,
          ),
        ),
        SizedBox(height: isCompact ? 8 : 12),
        // Category list scrolls when the screen is too short for all options;
        // Vazgeç stays pinned below so it is always reachable.
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: categories
                  .map(
                    (category) => Padding(
                      padding: EdgeInsets.only(bottom: isCompact ? 6 : 8),
                      child: _buildActionButton(
                        icon: Icons.menu_book_rounded,
                        label: category.displayName,
                        isCompact: isCompact,
                        onPressed: canMesk
                            ? () {
                                ref
                                    .read(gameProvider.notifier)
                                    .startMesk(category);
                              }
                            : null,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 4),
        _buildActionButton(
          icon: Icons.close_rounded,
          label: 'Vazgeç',
          isCompact: isCompact,
          onPressed: () {
            ref.read(gameProvider.notifier).cancelKiraathane();
          },
          muted: true,
        ),
      ],
    );
  }

  Widget _buildTitle(String title, bool isCompact) {
    return Row(
      children: [
        Icon(
          Icons.local_cafe_rounded,
          color: Colors.brown,
          size: isCompact ? 22 : 28,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: isCompact ? 17 : 22,
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
    bool isCompact = false,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: isCompact ? 18 : 20),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: muted ? Colors.grey.shade200 : Colors.brown.shade600,
        disabledBackgroundColor: Colors.grey.shade300,
        foregroundColor: muted ? Colors.black87 : Colors.white,
        disabledForegroundColor: Colors.grey.shade600,
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isCompact ? 8 : 14,
        ),
        minimumSize: const Size(0, 36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.poppins(
          fontSize: isCompact ? 13 : 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

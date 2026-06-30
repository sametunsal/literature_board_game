import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../data/book_config.dart';
import '../../../../core/motion/motion_constants.dart';
import '../../../../models/book_level.dart';
import '../../../providers/game_notifier.dart';
import '../../../providers/theme_notifier.dart';
import '../../dialogs/pause_dialog.dart';
import '../../dialogs/publishing_portfolio_dialog.dart';
import '../../dialogs/settings_dialog.dart';
import '../../screens/collection_screen.dart';
import '../../screens/main_menu_screen.dart';

enum _PublishingDebugActionType { jumpAndAsk, prepCilt }

class _PublishingDebugAction {
  final _PublishingDebugActionType type;
  final int tilePosition;

  const _PublishingDebugAction(this.type, this.tilePosition);
}

/// Overlay widget providing global board controls like Pause menu and Bot mode toggle
class GameControlsOverlay extends ConsumerStatefulWidget {
  const GameControlsOverlay({super.key});

  @override
  ConsumerState<GameControlsOverlay> createState() =>
      _GameControlsOverlayState();
}

class _GameControlsOverlayState extends ConsumerState<GameControlsOverlay> {
  bool _showPauseMenu = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // PAUSE BUTTON (top-right) - Buttons float below the P2 Profile Card
        Positioned(
          top: 140, // Moved down to clear the player panel
          right: 16,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPauseButton(),
                const SizedBox(height: 8),
                _buildPortfolioButton(),
                const SizedBox(height: 8),
                _buildBotModeButton(),
                if (kDebugMode) ...[
                  const SizedBox(height: 8),
                  _buildPublishingDebugMenu(),
                  const SizedBox(height: 8),
                  _buildPublishingDebugPanel(),
                ],
              ],
            ),
          ),
        ),

        // PAUSE MENU OVERLAY
        if (_showPauseMenu) _buildPauseOverlay(),
      ],
    );
  }

  /// Build the pause button with glass decoration
  Widget _buildPauseButton() {
    final themeState = ref.watch(themeProvider);
    final isDarkMode = themeState.isDarkMode;
    final tokens = themeState.tokens;

    return GestureDetector(
          onTap: () {
            ref.read(gameProvider.notifier).pauseGame();
            setState(() => _showPauseMenu = true);
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tokens.surface.withValues(alpha: isDarkMode ? 0.15 : 0.85),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: tokens.surface.withValues(alpha: isDarkMode ? 0.2 : 0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.pause, color: tokens.accent, size: 28),
          ),
        )
        .animate()
        .fadeIn(
          delay: MotionDurations.slow.safe,
          duration: MotionDurations.pulse.safe,
        )
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }

  Widget _buildPortfolioButton() {
    final themeState = ref.watch(themeProvider);
    final isDarkMode = themeState.isDarkMode;
    final tokens = themeState.tokens;

    return Tooltip(
          message: 'Yay\u0131n portf\u00f6y\u00fc',
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const PublishingPortfolioDialog(),
              );
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: tokens.surface.withValues(
                  alpha: isDarkMode ? 0.15 : 0.85,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: tokens.surface.withValues(
                    alpha: isDarkMode ? 0.2 : 0.5,
                  ),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.library_books_rounded,
                color: tokens.accent,
                size: 26,
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: MotionDurations.slow.safe,
          duration: MotionDurations.pulse.safe,
        )
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }

  /// Build the bot mode toggle button
  Widget _buildBotModeButton() {
    final themeState = ref.watch(themeProvider);
    final isDarkMode = themeState.isDarkMode;
    final tokens = themeState.tokens;
    final gameNotifier = ref.read(gameProvider.notifier);
    final isBotPlaying = gameNotifier.isBotPlaying;

    return GestureDetector(
          onTap: () {
            ref.read(gameProvider.notifier).toggleBotMode();
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isBotPlaying
                  ? Colors.green.withValues(alpha: 0.9)
                  : tokens.surface.withValues(alpha: isDarkMode ? 0.15 : 0.85),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isBotPlaying
                    ? Colors.greenAccent
                    : tokens.surface.withValues(alpha: isDarkMode ? 0.2 : 0.5),
                width: isBotPlaying ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isBotPlaying
                      ? Colors.green.withValues(alpha: 0.4)
                      : Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.smart_toy_rounded,
              color: isBotPlaying ? Colors.white : tokens.accent,
              size: 28,
            ),
          ),
        )
        .animate(
          onPlay: (controller) {
            if (isBotPlaying) {
              controller.repeat();
            }
          },
        )
        .shimmer(
          duration: const Duration(seconds: 2),
          color: isBotPlaying
              ? Colors.greenAccent.withValues(alpha: 0.5)
              : Colors.transparent,
        )
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: const Duration(milliseconds: 200),
        );
  }

  Widget _buildPublishingDebugPanel() {
    final themeState = ref.watch(themeProvider);
    final isDarkMode = themeState.isDarkMode;
    final tokens = themeState.tokens;
    final state = ref.watch(gameProvider);
    final currentPlayer = state.currentPlayer;
    final ownedBooks =
        state.bookOwnerships.values
            .where((ownership) => ownership.ownerPlayerId == currentPlayer.id)
            .toList()
          ..sort((a, b) => a.bookId.compareTo(b.bookId));

    return Container(
      width: 210,
      constraints: const BoxConstraints(maxHeight: 190),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: tokens.surface.withValues(alpha: isDarkMode ? 0.18 : 0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.orangeAccent.withValues(alpha: 0.65),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DefaultTextStyle(
        style: TextStyle(color: tokens.textPrimary, fontSize: 11, height: 1.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Publishing Debug',
              style: TextStyle(
                color: tokens.accent,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text('${currentPlayer.name} Akce: ${currentPlayer.akce}'),
            const SizedBox(height: 6),
            if (ownedBooks.isEmpty)
              const Text('Owned books: none')
            else
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final ownership in ownedBooks)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${BookConfig.getById(ownership.bookId)?.title ?? ownership.bookId}: ${ownership.level.displayName}',
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPublishingDebugMenu() {
    final themeState = ref.watch(themeProvider);
    final isDarkMode = themeState.isDarkMode;
    final tokens = themeState.tokens;

    return PopupMenuButton<_PublishingDebugAction>(
      tooltip: 'Publishing debug',
      onSelected: (action) async {
        final notifier = ref.read(gameProvider.notifier);
        switch (action.type) {
          case _PublishingDebugActionType.jumpAndAsk:
            notifier.debugJumpCurrentPlayerToPosition(action.tilePosition);
            await notifier.debugTriggerCurrentTile();
          case _PublishingDebugActionType.prepCilt:
            notifier.debugPrepareBookForCiltTest(action.tilePosition);
        }
      },
      itemBuilder: (context) => [
        for (final book in BookConfig.books)
          PopupMenuItem<_PublishingDebugAction>(
            value: _PublishingDebugAction(
              _PublishingDebugActionType.jumpAndAsk,
              book.tilePosition,
            ),
            child: Text('Jump + Ask: ${book.title} (${book.tilePosition})'),
          ),
        const PopupMenuDivider(),
        for (final book in BookConfig.books)
          PopupMenuItem<_PublishingDebugAction>(
            value: _PublishingDebugAction(
              _PublishingDebugActionType.prepCilt,
              book.tilePosition,
            ),
            child: Text('Prep Cilt: ${book.title} (${book.tilePosition})'),
          ),
      ],
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: tokens.surface.withValues(alpha: isDarkMode ? 0.15 : 0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.orangeAccent.withValues(alpha: 0.75),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.menu_book_rounded,
          color: Colors.orangeAccent,
          size: 26,
        ),
      ),
    );
  }

  /// Build the pause menu overlay
  Widget _buildPauseOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: PauseDialog(
          onResume: () {
            ref.read(gameProvider.notifier).resumeGame();
            setState(() => _showPauseMenu = false);
          },
          onSettings: () {
            showDialog(
              context: context,
              builder: (context) => const SettingsDialog(),
            );
          },

          onCollection: () {
            setState(() => _showPauseMenu = false);
            final state = ref.read(gameProvider);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CollectionScreen(
                  players: state.players,
                  initialPlayerIndex: state.currentPlayerIndex,
                ),
              ),
            );
          },
          onEndGame: () {
            setState(() => _showPauseMenu = false);
            ref.read(gameProvider.notifier).endGame();
          },
          onExit: () {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MainMenuScreen()),
              (route) => false,
            );
          },
        ),
      ),
    );
  }
}

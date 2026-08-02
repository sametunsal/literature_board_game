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
import 'board_visual_constants.dart';

enum _PublishingDebugActionType { jumpAndAsk, prepCilt }

class _PublishingDebugAction {
  final _PublishingDebugActionType type;
  final int tilePosition;

  const _PublishingDebugAction(this.type, this.tilePosition);
}

/// Overlay widget providing global board controls like Pause menu and Bot mode toggle
///
/// By default this is a full-viewport [Stack] that pins the button column to
/// the right screen edge. Set [embedded] to place the same buttons inline in a
/// parent-sized box (the right-side HUD column of the gameplay screen); in
/// that mode the pause menu is raised into the root [Overlay] so it still
/// covers the whole screen instead of being clipped to the column.
class GameControlsOverlay extends ConsumerStatefulWidget {
  /// When true, build only the button block sized to the parent's constraints
  /// instead of a screen-edge [Positioned] stack.
  final bool embedded;

  const GameControlsOverlay({super.key, this.embedded = false});

  @override
  ConsumerState<GameControlsOverlay> createState() =>
      _GameControlsOverlayState();
}

class _GameControlsOverlayState extends ConsumerState<GameControlsOverlay> {
  bool _showPauseMenu = false;
  OverlayEntry? _pauseEntry;

  @override
  void dispose() {
    _removePauseEntry();
    super.dispose();
  }

  void _removePauseEntry() {
    _pauseEntry?.remove();
    _pauseEntry = null;
  }

  void _openPauseMenu() {
    ref.read(gameProvider.notifier).pauseGame();
    if (!widget.embedded) {
      setState(() => _showPauseMenu = true);
      return;
    }
    // Embedded in the HUD column: the pause surface must cover the whole
    // screen, so it goes into the root overlay rather than this subtree.
    _removePauseEntry();
    final entry = OverlayEntry(builder: (_) => _buildPauseSurface());
    _pauseEntry = entry;
    Overlay.of(context, rootOverlay: true).insert(entry);
  }

  void _closePauseMenu() {
    if (widget.embedded) {
      _removePauseEntry();
      return;
    }
    setState(() => _showPauseMenu = false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) return _buildEmbeddedControls();

    return Stack(
      children: [
        // MENU BUTTONS (right edge) - anchored on the same edge line as the
        // player HUD cards, directly below the top-right HUD's clearance so
        // the column hugs the device edge instead of floating over the board.
        Positioned(
          top: kHudEdgeClearance,
          right: kEdgeControlsInset,
          child: SafeArea(
            left: false,
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildPauseButton(),
                const SizedBox(height: kMenuButtonSpacing),
                _buildPortfolioButton(),
                const SizedBox(height: kMenuButtonSpacing),
                _buildBotModeButton(),
                if (kDebugMode) ...[
                  const SizedBox(height: kMenuButtonSpacing),
                  _buildPublishingDebugMenu(),
                  const SizedBox(height: kMenuButtonSpacing),
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

  /// Inline button block for the right-side HUD column.
  ///
  /// A [Wrap] reflows the square buttons to however many fit the column width,
  /// so a narrow column stacks them into more rows instead of overflowing.
  Widget _buildEmbeddedControls() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // The fixed-width debug panel only fits a column wide enough to host
        // the game log; narrower columns show the debug menu button alone.
        final hasRoomForDebugPanel = constraints.maxWidth >= 220;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: kMenuButtonSpacing,
              runSpacing: kMenuButtonSpacing,
              alignment: WrapAlignment.end,
              children: [
                _buildPauseButton(),
                _buildPortfolioButton(),
                _buildBotModeButton(),
                if (kDebugMode) _buildPublishingDebugMenu(),
              ],
            ),
            if (kDebugMode && hasRoomForDebugPanel) ...[
              const SizedBox(height: kMenuButtonSpacing),
              _buildPublishingDebugPanel(),
            ],
          ],
        );
      },
    );
  }

  /// Build the pause button with glass decoration
  Widget _buildPauseButton() {
    final themeState = ref.watch(themeProvider);
    final isDarkMode = themeState.isDarkMode;
    final tokens = themeState.tokens;

    return GestureDetector(
          onTap: _openPauseMenu,
          child: Container(
            width: kMenuButtonSize,
            height: kMenuButtonSize,
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
              width: kMenuButtonSize,
              height: kMenuButtonSize,
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
            width: kMenuButtonSize,
            height: kMenuButtonSize,
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
            Text('${currentPlayer.name} Akçe: ${currentPlayer.akce}'),
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
        width: kMenuButtonSize,
        height: kMenuButtonSize,
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
    return Positioned.fill(child: _buildPauseSurface());
  }

  /// The scrim + pause dialog itself, without any positioning, so it can be
  /// used either as a [Positioned.fill] child or as a root [OverlayEntry].
  Widget _buildPauseSurface() {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: PauseDialog(
        onResume: () {
          ref.read(gameProvider.notifier).resumeGame();
          _closePauseMenu();
        },
        onSettings: () {
          showDialog(
            context: context,
            builder: (context) => const SettingsDialog(),
          );
        },

        onCollection: () {
          _closePauseMenu();
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
          _closePauseMenu();
          ref.read(gameProvider.notifier).endGame();
        },
        onExit: () {
          _removePauseEntry();
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
    );
  }
}

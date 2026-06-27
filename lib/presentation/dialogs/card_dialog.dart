import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/game_constants.dart';
import '../../models/game_card.dart';
import '../../models/game_enums.dart';
import '../../providers/game_notifier.dart';
import '../theme/card_visual_theme.dart';

/// Card dialog with auto-dismiss timer.
class CardDialog extends ConsumerStatefulWidget {
  final GameCard card;
  final VoidCallback? onDismiss;

  const CardDialog({super.key, required this.card, this.onDismiss});

  @override
  ConsumerState<CardDialog> createState() => _CardDialogState();
}

class _CardDialogState extends ConsumerState<CardDialog>
    with SingleTickerProviderStateMixin {
  static const Duration _entranceDuration = Duration(milliseconds: 280);
  static const Duration _exitDuration = Duration(milliseconds: 150);

  Timer? _autoDismissTimer;
  double _progress = 1.0;
  Timer? _progressTimer;
  late final AnimationController _motionController;
  late final Animation<double> _fadeAnimation;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _motionController = AnimationController(
      vsync: this,
      duration: _entranceDuration,
      reverseDuration: _exitDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _motionController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _motionController.forward();
    _startAutoDismiss();
  }

  void _startAutoDismiss() {
    const duration = Duration(milliseconds: GameConstants.cardDialogDurationMs);
    const tickRate = Duration(milliseconds: 50);
    final totalTicks = duration.inMilliseconds / tickRate.inMilliseconds;
    int currentTick = 0;

    _progressTimer = Timer.periodic(tickRate, (timer) {
      currentTick++;
      if (mounted) {
        setState(() {
          _progress = 1.0 - (currentTick / totalTicks);
        });
      }
    });

    _autoDismissTimer = Timer(duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    if (_isDismissing) return;
    _isDismissing = true;

    _motionController.reverse().whenComplete(() {
      if (!mounted) return;
      final onDismiss = widget.onDismiss;
      if (onDismiss != null) {
        onDismiss();
        return;
      }
      ref.read(gameProvider.notifier).closeCardDialog();
    });
  }

  void _cancelTimerAndDismiss() {
    _autoDismissTimer?.cancel();
    _progressTimer?.cancel();
    _dismiss();
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _progressTimer?.cancel();
    _motionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final isSans = card.type == CardType.sans;
    final visualTheme = CardVisualTheme.forType(card.type);
    final scaleAnimation = Tween<double>(begin: isSans ? 0.96 : 1.03, end: 1)
        .animate(
          CurvedAnimation(
            parent: _motionController,
            curve: Curves.easeOutCubic,
          ),
        );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        minimum: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compactHeight = constraints.maxHeight < 420;
            final tightHeight = constraints.maxHeight < 320;
            final outerPadding = tightHeight
                ? 12.0
                : compactHeight
                ? 16.0
                : 24.0;
            final iconPadding = tightHeight ? 8.0 : 16.0;
            final iconSize = tightHeight
                ? 32.0
                : compactHeight
                ? 40.0
                : 50.0;
            final gap = tightHeight
                ? 8.0
                : compactHeight
                ? 12.0
                : 16.0;
            final descriptionGap = tightHeight ? 8.0 : 20.0;
            final footerGap = tightHeight ? 8.0 : 16.0;
            final titleFontSize = tightHeight ? 15.0 : 18.0;

            return Stack(
              children: [
                if (!isSans)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.28),
                            ],
                            stops: const [0.55, 1],
                          ),
                        ),
                      ),
                    ),
                  ),
                Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: scaleAnimation,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 400,
                          maxHeight: constraints.maxHeight,
                        ),
                        child: GestureDetector(
                          onTap: _cancelTimerAndDismiss,
                          child: Container(
                            padding: EdgeInsets.all(outerPadding),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: visualTheme.background,
                                stops: const [0, 0.62, 1],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: visualTheme.metallic.withValues(
                                  alpha: 0.9,
                                ),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: visualTheme.shadow.withValues(
                                    alpha: 0.5,
                                  ),
                                  blurRadius: 28,
                                  offset: const Offset(0, 12),
                                ),
                                if (isSans)
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFFD36A,
                                    ).withValues(alpha: 0.24),
                                    blurRadius: 34,
                                    spreadRadius: 4,
                                  ),
                              ],
                            ),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: _progress,
                                    backgroundColor: visualTheme.foreground
                                        .withValues(alpha: 0.16),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      visualTheme.metallic,
                                    ),
                                    minHeight: 4,
                                  ),
                                ),
                                SizedBox(height: gap),
                                Container(
                                  padding: EdgeInsets.all(iconPadding),
                                  decoration: BoxDecoration(
                                    color: visualTheme.surface.withValues(
                                      alpha: isSans ? 0.78 : 0.3,
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: visualTheme.metallic,
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: visualTheme.accent.withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    visualTheme.icon,
                                    size: iconSize,
                                    color: isSans
                                        ? visualTheme.accent
                                        : visualTheme.metallic,
                                  ),
                                ),
                                SizedBox(height: gap),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: tightHeight ? 12 : 16,
                                    vertical: tightHeight ? 6 : 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        visualTheme.accent,
                                        visualTheme.shadow,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: visualTheme.metallic.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.2,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    visualTheme.title,
                                    style: GoogleFonts.playfairDisplay(
                                      fontWeight: FontWeight.bold,
                                      fontSize: titleFontSize,
                                      color: visualTheme.foreground,
                                    ),
                                  ),
                                ),
                                SizedBox(height: descriptionGap),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: AutoSizeText(
                                      card.description,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        color: visualTheme.foreground,
                                        height: 1.5,
                                      ),
                                      minFontSize: 12,
                                    ),
                                  ),
                                ),
                                SizedBox(height: footerGap),
                                Text(
                                  'Kapatmak için dokun',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: visualTheme.mutedForeground
                                        .withValues(alpha: 0.8),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/game_theme.dart';

/// Game log widget with modern glassmorphism effect
/// Displays recent game events as a floating glass panel
class GameLog extends StatelessWidget {
  final List<String> logs;

  const GameLog({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    // Show last 5 messages
    final displayLogs = logs.length > 5 ? logs.sublist(logs.length - 5) : logs;

    if (displayLogs.isEmpty) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            // Blur effect for glassmorphism
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 260,
              constraints: const BoxConstraints(maxHeight: 180),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // Semi-transparent white for glass effect
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                // Thin white border for glass edge
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
                // Subtle inner shadow for depth
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  _buildHeader(),
                  const SizedBox(height: 8),

                  // DIVIDER
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: 0.3),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // LOG ENTRIES (scrollable)
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: displayLogs
                            .asMap()
                            .entries
                            .map(
                              (entry) => _LogEntry(
                                text: entry.value,
                                isLatest: entry.key == displayLogs.length - 1,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.history, size: 16, color: GameTheme.goldAccent),
        const SizedBox(width: 8),
        Text(
          "OYUN GEÇMİŞİ",
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
            shadows: [
              Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4),
            ],
          ),
        ),
      ],
    );
  }
}

/// Individual log entry with styling
class _LogEntry extends StatelessWidget {
  final String text;
  final bool isLatest;

  const _LogEntry({required this.text, this.isLatest = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bullet point
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: isLatest
                  ? GameTheme.goldAccent
                  : Colors.white.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),

          // Log text
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isLatest ? FontWeight.w500 : FontWeight.normal,
                color: isLatest
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.8),
                height: 1.3,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

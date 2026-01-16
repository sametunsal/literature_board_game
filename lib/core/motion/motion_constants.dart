import 'package:flutter/widgets.dart';

/// Central motion constants for consistent animations across the app.
/// Use these instead of hardcoded durations and curves.
///
/// ACCESSIBILITY
/// Check if user has requested reduced motion (accessibility setting)
bool get reduceMotion => WidgetsBinding
    .instance
    .platformDispatcher
    .accessibilityFeatures
    .disableAnimations;

// ═══════════════════════════════════════════════════════════════════════════
// DURATIONS
// ═══════════════════════════════════════════════════════════════════════════

/// Standard animation durations for consistent timing across the app.
/// Use with `.safe` extension to respect reduced motion settings.
///
/// Example: `MotionDurations.medium.safe`
class MotionDurations {
  MotionDurations._(); // Prevent instantiation

  /// 150ms - Micro-interactions, hover, press feedback
  static const Duration fast = Duration(milliseconds: 150);

  /// 300ms - Standard transitions, default animations
  static const Duration medium = Duration(milliseconds: 300);

  /// 500ms - Emphasis, page/screen transitions
  static const Duration slow = Duration(milliseconds: 500);

  /// 350ms - Dialog open/close animations
  static const Duration dialog = Duration(milliseconds: 350);

  /// 400ms - Pawn hop animation on board
  static const Duration pawn = Duration(milliseconds: 400);

  /// 800ms - Dice roll and settle animation
  static const Duration dice = Duration(milliseconds: 800);

  /// 2000ms - Confetti celebration duration
  static const Duration confetti = Duration(milliseconds: 2000);

  // ─────────────────────────────────────────────────────────────────────────
  // Ambient / Long-running animations
  // ─────────────────────────────────────────────────────────────────────────

  /// 8 seconds - Ambient gradient background breathing animation
  static const Duration ambientGradient = Duration(seconds: 8);

  /// 3000ms - Long shimmer effects (logo, decorative)
  static const Duration shimmerLong = Duration(milliseconds: 3000);

  /// 2500ms - Medium shimmer effects (title, highlights)
  static const Duration shimmerMedium = Duration(milliseconds: 2500);

  // ─────────────────────────────────────────────────────────────────────────
  // Computed / Derived durations
  // ─────────────────────────────────────────────────────────────────────────

  /// 1000ms - Double slow duration for extended transitions
  static const Duration slowDouble = Duration(milliseconds: 1000);

  /// 350ms - Tile landing pulse animation
  static const Duration pulse = Duration(milliseconds: 350);
}

// ═══════════════════════════════════════════════════════════════════════════
// CURVES
// ═══════════════════════════════════════════════════════════════════════════

/// Standard animation curves for consistent motion feel.
class MotionCurves {
  MotionCurves._(); // Prevent instantiation

  /// Default curve for most UI transitions (easeOutCubic)
  static const Curve standard = Curves.easeOutCubic;

  /// Pop-in effect for dialogs and emphasized entrances (easeOutBack)
  static const Curve emphasized = Curves.easeOutBack;

  /// Settling motion, dice stopping (decelerate)
  static const Curve decelerate = Curves.decelerate;

  /// Bouncy feedback, playful interactions (elasticOut)
  static const Curve spring = Curves.elasticOut;
}

// ═══════════════════════════════════════════════════════════════════════════
// EXTENSIONS
// ═══════════════════════════════════════════════════════════════════════════

/// Extension to make durations accessibility-aware.
/// Returns Duration.zero when reduce motion is enabled.
extension SafeDuration on Duration {
  /// Returns this duration, or Duration.zero if reduce motion is enabled.
  /// Use this for all animations to respect accessibility settings.
  Duration get safe => reduceMotion ? Duration.zero : this;
}

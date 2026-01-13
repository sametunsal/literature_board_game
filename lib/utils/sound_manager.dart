import 'package:audioplayers/audioplayers.dart';

/// Singleton Sound Manager for game audio effects
/// Provides all sound effects for immersive gameplay experience
class SoundManager {
  // Private constructor
  SoundManager._();

  // Singleton instance
  static final SoundManager instance = SoundManager._();

  // Audio player instance
  final AudioPlayer _player = AudioPlayer();

  // Sound file paths (assets/sounds/)
  // NOTE: Using existing assets - add custom sounds later for better experience
  static const String _clickSound = 'sounds/click.mp3';
  static const String _diceRollSound = 'sounds/dice.mp3'; // Existing dice sound
  static const String _diceLandSound =
      'sounds/click.mp3'; // Use click as thud placeholder
  static const String _tileLandingSound =
      'sounds/click.mp3'; // Use click as landing placeholder
  static const String _correctAnswerSound =
      'sounds/victory.mp3'; // Use victory for success
  static const String _wrongAnswerSound =
      'sounds/click.mp3'; // Use click as buzzer placeholder
  static const String _purchaseSound =
      'sounds/click.mp3'; // Use click as cash placeholder
  static const String _victorySound = 'sounds/victory.mp3';
  static const String _turnChangeSound =
      'sounds/click.mp3'; // Use click as whoosh placeholder
  static const String _timerTickSound =
      'sounds/click.mp3'; // Use click as tick placeholder

  /// Helper method to play sound with error handling
  Future<void> _playSound(String path) async {
    try {
      await _player.stop(); // Prevent overlap
      await _player.play(AssetSource(path));
    } catch (e) {
      // Silently fail if sound not available
      // Sound assets may not exist yet - this is safe to ignore
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // DICE SOUNDS
  // ════════════════════════════════════════════════════════════════════════════

  /// Play dice roll animation sound
  Future<void> playDiceRoll() async {
    await _playSound(_diceRollSound);
  }

  /// Play dice landing "thud" sound
  Future<void> playDiceLand() async {
    await _playSound(_diceLandSound);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // TILE & MOVEMENT SOUNDS
  // ════════════════════════════════════════════════════════════════════════════

  /// Play sound when pawn lands on a tile
  Future<void> playTileLanding() async {
    await _playSound(_tileLandingSound);
  }

  /// Play turn change whoosh
  Future<void> playTurnChange() async {
    await _playSound(_turnChangeSound);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // QUESTION & ANSWER SOUNDS
  // ════════════════════════════════════════════════════════════════════════════

  /// Play correct answer celebration sound
  Future<void> playCorrectAnswer() async {
    await _playSound(_correctAnswerSound);
  }

  /// Play wrong answer buzzer sound
  Future<void> playWrongAnswer() async {
    await _playSound(_wrongAnswerSound);
  }

  /// Play timer tick for countdown urgency
  Future<void> playTimerTick() async {
    await _playSound(_timerTickSound);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ECONOMY SOUNDS
  // ════════════════════════════════════════════════════════════════════════════

  /// Play purchase/buy sound (coins/cash register)
  Future<void> playPurchase() async {
    await _playSound(_purchaseSound);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // UI SOUNDS
  // ════════════════════════════════════════════════════════════════════════════

  /// Play click sound for button taps
  Future<void> playClick() async {
    await _playSound(_clickSound);
  }

  /// Play victory fanfare for game end
  Future<void> playVictory() async {
    await _playSound(_victorySound);
  }

  /// Dispose of audio resources
  void dispose() {
    _player.dispose();
  }
}

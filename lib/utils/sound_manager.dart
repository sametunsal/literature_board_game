import 'package:audioplayers/audioplayers.dart';

/// Singleton Sound Manager for game audio effects
class SoundManager {
  // Private constructor
  SoundManager._();

  // Singleton instance
  static final SoundManager instance = SoundManager._();

  // Audio player instance
  final AudioPlayer _player = AudioPlayer();

  // Sound file paths
  static const String _clickSound = 'sounds/click.mp3';
  static const String _diceSound = 'sounds/dice.mp3';
  static const String _victorySound = 'sounds/victory.mp3';

  /// Play click sound for button taps
  Future<void> playClick() async {
    try {
      await _player.play(AssetSource(_clickSound));
    } catch (e) {
      // Silently fail if sound not available
      print('SoundManager: Could not play click sound: $e');
    }
  }

  /// Play dice roll sound
  Future<void> playDice() async {
    try {
      await _player.play(AssetSource(_diceSound));
    } catch (e) {
      print('SoundManager: Could not play dice sound: $e');
    }
  }

  /// Play victory fanfare
  Future<void> playVictory() async {
    try {
      await _player.play(AssetSource(_victorySound));
    } catch (e) {
      print('SoundManager: Could not play victory sound: $e');
    }
  }

  /// Dispose of audio resources
  void dispose() {
    _player.dispose();
  }
}

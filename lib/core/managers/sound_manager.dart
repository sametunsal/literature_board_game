import 'audio_manager.dart';

/// Legacy Sound Manager wrapper
/// Delegates calls to the new AudioManager
class SoundManager {
  // Private constructor
  SoundManager._();

  // Singleton instance
  static final SoundManager instance = SoundManager._();

  bool get isSoundEnabled => AudioManager.instance.isSoundEnabled;
  bool get isMusicEnabled => AudioManager.instance.isMusicEnabled;

  void setSoundEnabled(bool enabled) {
    AudioManager.instance.toggleSound(enabled);
  }

  void setMusicEnabled(bool enabled) {
    AudioManager.instance.toggleMusic(enabled);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // DELEGATED METHODS
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> playDiceRoll() async =>
      await AudioManager.instance.playDiceRoll();

  Future<void> playDiceLand() async =>
      await AudioManager.instance.playSfx('sounds/click.mp3'); // Placeholder

  Future<void> playTileLanding() async =>
      await AudioManager.instance.playSfx('sounds/click.mp3'); // Placeholder

  Future<void> playTurnChange() async =>
      await AudioManager.instance.playSfx('sounds/click.mp3'); // Placeholder

  Future<void> playCorrectAnswer() async =>
      await AudioManager.instance.playSfx('sounds/victory.mp3');

  Future<void> playWrongAnswer() async =>
      await AudioManager.instance.playSfx('sounds/click.mp3'); // Placeholder

  Future<void> playTimerTick() async =>
      await AudioManager.instance.playSfx('sounds/click.mp3'); // Placeholder

  Future<void> playPurchase() async =>
      await AudioManager.instance.playSfx('sounds/click.mp3'); // Placeholder

  Future<void> playClick() async => await AudioManager.instance.playClick();

  Future<void> playVictory() async => await AudioManager.instance.playVictory();

  void dispose() {
    // AudioManager disposes itself
  }
}

import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Singleton Audio Manager for game music and sound effects
/// Handles BGM playlist (looping) and concurrent SFX playback
class AudioManager {
  // Private constructor
  AudioManager._() {
    // Listen for BGM completion to loop/play next
    _bgmPlayer.onPlayerComplete.listen((_) {
      _playNextBgm();
    });
  }

  // Singleton instance
  static final AudioManager instance = AudioManager._();

  // Players
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  // State
  bool _isMusicEnabled = true;
  bool _isSoundEnabled = true;
  int _currentBgmIndex = 0;

  // BGM Playlist
  final List<String> _bgmPlaylist = [
    'audio/bgm_1.mp3',
    'audio/bgm_2.mp3',
    'audio/bgm_3.mp3',
    'audio/bgm_4.mp3',
  ];

  // Volume Settings (mutable state)
  double _bgmVolume = 1.0; // Slider position (0.0 - 1.0), stored for UI
  double _sfxVolume = 1.0; // 100% volume for effects

  // Volume Gain Limits
  /// Maximum actual BGM output volume (35% cap to prevent overpowering SFX)
  static const double _maxBgmGain = 0.35;

  // Getters
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSoundEnabled => _isSoundEnabled;
  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;

  // ════════════════════════════════════════════════════════════════════════════
  // VOLUME CONTROLS
  // ════════════════════════════════════════════════════════════════════════════

  /// Set BGM volume with validation (0.0 to 1.0)
  /// [value] is the slider position (0.0 - 1.0), stored for UI display
  /// Actual player volume is scaled by [_maxBgmGain] to prevent overpowering SFX
  Future<void> setBgmVolume(double value) async {
    final sliderValue = value.clamp(0.0, 1.0);
    _bgmVolume = sliderValue; // Store raw slider position for UI
    final actualVolume = sliderValue * _maxBgmGain; // Apply gain reduction
    await _bgmPlayer.setVolume(actualVolume);
    debugPrint('🎵 BGM Volume: slider=$sliderValue, actual=$actualVolume');
  }

  /// Set SFX volume with validation (0.0 to 1.0)
  /// Applied on next SFX playback
  void setSfxVolume(double value) {
    final clampedValue = value.clamp(0.0, 1.0);
    _sfxVolume = clampedValue;
    debugPrint('🔊 SFX Volume set to: $clampedValue');
  }

  // ════════════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ════════════════════════════════════════════════════════════════════════════

  /// Initialize and start BGM
  Future<void> init() async {
    // Apply scaled BGM volume (slider value * max gain)
    await _bgmPlayer.setVolume(_bgmVolume * _maxBgmGain);
    await _sfxPlayer.setVolume(_sfxVolume);

    // Release mode only: Start BGM if enabled
    if (kReleaseMode || true) {
      // Enabled in debug for now to test
      await startBgm();
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // BGM CONTROLS
  // ════════════════════════════════════════════════════════════════════════════

  /// Start playing BGM from current index
  Future<void> startBgm() async {
    if (!_isMusicEnabled || _bgmPlaylist.isEmpty) return;

    try {
      final track = _bgmPlaylist[_currentBgmIndex];
      debugPrint('🎵 Playing BGM: $track');
      await _bgmPlayer.play(AssetSource(track));
    } catch (e) {
      debugPrint('🚨 Error playing BGM: $e');
    }
  }

  /// Play next track in playlist (Looping)
  void _playNextBgm() {
    _currentBgmIndex = (_currentBgmIndex + 1) % _bgmPlaylist.length;
    startBgm();
  }

  /// Stop BGM
  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
  }

  /// Pause BGM
  Future<void> pauseBgm() async {
    await _bgmPlayer.pause();
  }

  /// Resume BGM
  Future<void> resumeBgm() async {
    if (_isMusicEnabled) {
      await _bgmPlayer.resume();
    }
  }

  /// Toggle Music
  void toggleMusic(bool enabled) {
    _isMusicEnabled = enabled;
    if (enabled) {
      // If resuming from disabled state, start playing
      if (_bgmPlayer.state != PlayerState.playing) {
        startBgm();
      }
    } else {
      stopBgm();
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SFX CONTROLS
  // ════════════════════════════════════════════════════════════════════════════

  /// Play a sound effect
  /// [fileName] should be relative to assets/ (e.g., 'audio/click.mp3')
  /// or use provided helper methods
  Future<void> playSfx(String fileName) async {
    if (!_isSoundEnabled) return;

    try {
      // Create a temporary player for overlapping SFX if needed,
      // but for now reusing _sfxPlayer is more efficient for mobile
      if (_sfxPlayer.state == PlayerState.playing) {
        await _sfxPlayer.stop();
      }
      // Apply current SFX volume before playback
      await _sfxPlayer.setVolume(_sfxVolume);
      await _sfxPlayer.play(AssetSource(fileName));
    } catch (e) {
      debugPrint('🚨 Error playing SFX: $e');
    }
  }

  /// Toggle Sound Effects
  void toggleSound(bool enabled) {
    _isSoundEnabled = enabled;
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PRESET SFX HELPERS
  // ════════════════════════════════════════════════════════════════════════════

  // These map to existing assets/sounds/ paths based on SoundManager usage
  // We can migrate SoundManager to use this later

  Future<void> playClick() => playSfx('sounds/click.mp3');
  Future<void> playDiceRoll() => playSfx('sounds/dice.mp3');
  Future<void> playVictory() => playSfx('sounds/victory.mp3');

  /// Dispose resources
  void dispose() {
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
  }
}

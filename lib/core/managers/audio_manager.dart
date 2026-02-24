import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import '../utils/logger.dart';

/// Audio context for different game states
enum AudioContext {
  menu, // Main menu, settings, how to play
  game, // Board game, pause menu
}

/// Singleton Audio Manager for game music and sound effects
/// Handles context-aware BGM playlists with seamless transitions
/// and concurrent SFX playback
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

  // Random number generator for playlist shuffling
  final Random _random = Random();

  // Fade Timer
  Timer? _fadeTimer;

  // State
  bool _isMusicEnabled = true;
  bool _isSoundEnabled = true;
  int _currentBgmIndex = 0;
  AudioContext _currentContext = AudioContext.menu;

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // CONTEXT-AWARE PLAYLISTS
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  /// Menu BGM Playlist - Used in Main Menu, Settings, How to Play
  final List<String> _menuPlaylist = [
    'audio/menu_bg1.mp3',
    'audio/menu_bg2.mp3',
    'audio/menu_bg3.mp3',
    'audio/menu_bg4.mp3',
  ];

  /// In-Game BGM Playlist - Used during board game and pause menu
  final List<String> _gamePlaylist = [
    'audio/ingame_bg1.mp3',
    'audio/ingame_bg2.mp3',
    'audio/ingame_bg3.mp3',
    'audio/ingame_bg4.mp3',
  ];

  /// Get the active playlist based on current context
  List<String> get _activePlaylist {
    return _currentContext == AudioContext.menu ? _menuPlaylist : _gamePlaylist;
  }

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
  AudioContext get currentContext => _currentContext;

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // VOLUME CONTROLS
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  /// Set BGM volume with validation (0.0 to 1.0)
  /// [value] is the slider position (0.0 - 1.0), stored for UI display
  /// Actual player volume is scaled by [_maxBgmGain] to prevent overpowering SFX
  Future<void> setBgmVolume(double value) async {
    final sliderValue = value.clamp(0.0, 1.0);
    _bgmVolume = sliderValue; // Store raw slider position for UI
    final actualVolume = sliderValue * _maxBgmGain; // Apply gain reduction
    await _bgmPlayer.setVolume(actualVolume);
    safePrint('ğŸµ BGM Volume: slider=$sliderValue, actual=$actualVolume');
  }

  /// Set SFX volume with validation (0.0 to 1.0)
  /// Applied on next SFX playback
  void setSfxVolume(double value) {
    final clampedValue = value.clamp(0.0, 1.0);
    _sfxVolume = clampedValue;
    safePrint('ğŸ”Š SFX Volume set to: $clampedValue');
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // FADE CONTROLS
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  /// Fade in BGM from 0.0 to target volume over [duration]
  /// [duration] defaults to 2 seconds for smooth, subtle entrance
  Future<void> _fadeInBgm({
    Duration duration = const Duration(seconds: 2),
  }) async {
    // Cancel any existing fade operation
    _fadeTimer?.cancel();

    if (!_isMusicEnabled || _activePlaylist.isEmpty) return;

    final targetVolume = _bgmVolume * _maxBgmGain;
    const stepCount = 20; // Number of fade steps
    final stepDuration = duration.inMilliseconds ~/ stepCount;
    final volumeStep = targetVolume / stepCount;

    safePrint(
      'ğŸµ Fading in BGM: 0.0 â†’ $targetVolume over ${duration.inSeconds}s',
    );

    // Start at 0 volume
    await _bgmPlayer.setVolume(0.0);

    try {
      final track = _activePlaylist[_currentBgmIndex];
      await _bgmPlayer.play(AssetSource(track));
      safePrint('ğŸµ Playing: $track (context: $_currentContext)');
    } catch (e) {
      safePrint('ğŸš¨ Error playing BGM: $e');
      return;
    }

    // Gradually increase volume
    int currentStep = 0;
    _fadeTimer = Timer.periodic(Duration(milliseconds: stepDuration), (timer) {
      currentStep++;
      final newVolume = (volumeStep * currentStep).clamp(0.0, targetVolume);
      _bgmPlayer.setVolume(newVolume);

      if (currentStep >= stepCount) {
        timer.cancel();
        safePrint('ğŸµ Fade in complete');
      }
    });
  }

  /// Fade out BGM from current volume to 0.0 over [duration]
  /// [duration] defaults to 1 second for quick but smooth exit
  /// Stops playback only when volume reaches 0
  Future<void> _fadeOutBgm({
    Duration duration = const Duration(seconds: 1),
  }) async {
    // Cancel any existing fade operation
    _fadeTimer?.cancel();

    final currentVolume = _bgmVolume * _maxBgmGain;
    if (currentVolume <= 0.01) {
      // Already at or near zero, just stop
      await _bgmPlayer.stop();
      return;
    }

    const stepCount = 20; // Number of fade steps
    final stepDuration = duration.inMilliseconds ~/ stepCount;
    final volumeStep = currentVolume / stepCount;

    safePrint(
      'ğŸµ Fading out BGM: $currentVolume â†’ 0.0 over ${duration.inSeconds}s',
    );

    // Gradually decrease volume
    int currentStep = 0;
    _fadeTimer = Timer.periodic(Duration(milliseconds: stepDuration), (
      timer,
    ) async {
      currentStep++;
      final newVolume = (currentVolume - (volumeStep * currentStep)).clamp(
        0.0,
        currentVolume,
      );
      await _bgmPlayer.setVolume(newVolume);

      if (currentStep >= stepCount) {
        timer.cancel();
        await _bgmPlayer.stop();
        safePrint('ğŸµ Fade out complete');
      }
    });
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // INITIALIZATION
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  /// Initialize and start Menu BGM
  Future<void> init() async {
    // Apply scaled BGM volume (slider value * max gain)
    await _bgmPlayer.setVolume(_bgmVolume * _maxBgmGain);
    await _sfxPlayer.setVolume(_sfxVolume);

    // Start with menu context
    _currentContext = AudioContext.menu;
    await _fadeInBgm();
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // CONTEXT-AWARE BGM CONTROLS
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  /// Play Menu BGM (Main Menu, Settings, How to Play)
  /// Seamlessly transitions from game music if needed
  /// Does NOT restart if already in menu context
  Future<void> playMenuBgm() async {
    // Seamless: If already in menu context and music is playing, do nothing
    if (_currentContext == AudioContext.menu &&
        _bgmPlayer.state == PlayerState.playing) {
      safePrint('ğŸµ Already in menu context with music playing - seamless');
      return;
    }

    safePrint('ğŸµ Switching to Menu BGM...');
    _currentContext = AudioContext.menu;

    if (_bgmPlayer.state == PlayerState.playing) {
      // Fade out current, then fade in menu
      await _fadeOutBgm(duration: const Duration(milliseconds: 800));
      await Future.delayed(const Duration(milliseconds: 200));
      _currentBgmIndex = _random.nextInt(_menuPlaylist.length);
      await _fadeInBgm(duration: const Duration(seconds: 2));
    } else {
      // Start fresh
      _currentBgmIndex = _random.nextInt(_menuPlaylist.length);
      await _fadeInBgm();
    }
  }

  /// Play In-Game BGM (Board Game, Pause Menu)
  /// Seamlessly transitions from menu music if needed
  /// Does NOT restart if already in game context
  Future<void> playInGameBgm() async {
    // Seamless: If already in game context and music is playing, do nothing
    if (_currentContext == AudioContext.game &&
        _bgmPlayer.state == PlayerState.playing) {
      safePrint('ğŸµ Already in game context with music playing - seamless');
      return;
    }

    safePrint('ğŸµ Switching to In-Game BGM...');
    _currentContext = AudioContext.game;

    if (_bgmPlayer.state == PlayerState.playing) {
      // Fade out current, then fade in game
      await _fadeOutBgm(duration: const Duration(milliseconds: 800));
      await Future.delayed(const Duration(milliseconds: 200));
      _currentBgmIndex = _random.nextInt(_gamePlaylist.length);
      await _fadeInBgm(duration: const Duration(seconds: 2));
    } else {
      // Start fresh
      _currentBgmIndex = _random.nextInt(_gamePlaylist.length);
      await _fadeInBgm();
    }
  }

  /// Play next track in current playlist (Looping)
  void _playNextBgm() {
    _currentBgmIndex = (_currentBgmIndex + 1) % _activePlaylist.length;
    _fadeInBgm();
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // LEGACY BGM CONTROLS (Deprecated - use context-aware methods)
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  /// Start playing BGM from current index with fade-in
  /// @deprecated Use playMenuBgm() or playInGameBgm() for context-aware music
  Future<void> startBgm() async {
    if (!_isMusicEnabled || _activePlaylist.isEmpty) return;
    await _fadeInBgm();
  }

  /// Stop BGM with fade-out
  Future<void> stopBgm() async {
    await _fadeOutBgm();
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
        _currentContext == AudioContext.menu ? playMenuBgm() : playInGameBgm();
      }
    } else {
      stopBgm();
    }
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // SFX CONTROLS
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  /// Play a sound effect
  /// [fileName] should be relative to assets/ (e.g., 'audio/click.wav')
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
      safePrint('ğŸš¨ Error playing SFX: $e');
    }
  }

  /// Toggle Sound Effects
  void toggleSound(bool enabled) {
    _isSoundEnabled = enabled;
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // PRESET SFX HELPERS
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  Future<void> playClick() => playSfx('audio/ui_click.wav');
  Future<void> playDiceRoll() => playSfx('audio/dice_roll.wav');
  Future<void> playVictory() => playSfx('audio/correct.wav');
  Future<void> playWrong() => playSfx('audio/wrong.wav');
  Future<void> playCardFlip() => playSfx('audio/card_flip.wav');
  Future<void> playPawnStep() => playSfx('audio/pawn_step.wav');

  /// Dispose resources
  void dispose() {
    _fadeTimer?.cancel();
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
  }
}

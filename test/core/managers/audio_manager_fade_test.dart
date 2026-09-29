import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/core/managers/audio_manager.dart';

/// Regression tests for the BGM fade race (BUG-002).
///
/// `_fadeOutBgm` runs its steps in an async `Timer.periodic` callback whose
/// final `stop()` was never synchronised with anything. When a newer fade
/// started (context switch, stop-then-start, dispose), the stale fade-out
/// kept running and its `stop()` could land on the player the newer fade
/// already took over — killing the new track mid-fade-in.
///
/// The fade generation token now makes any superseded fade callback a
/// no-op. These tests drive that contract through the public API: after a
/// newer fade takes over, the superseded fade must neither step the volume
/// nor stop the player.
///
/// Tests share the [AudioManager] singleton (one per process) and run as
/// one ordered scenario. `play()` fails in the test environment (no asset
/// backend) and is caught by AudioManager itself; the generation bump
/// happens before that, so the takeover semantics stay exercised.
void main() {
  // All player platform calls (create/setVolume/setSourceUrl/resume/stop)
  // go through this single method channel; recording it captures the exact
  // call order the fades produce.
  final calls = <String>[];

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (call) async => null,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (call) async {
        calls.add(call.method);
        return null;
      },
    );
  });

  test('a newer fade must supersede the running fade-out stop', () async {
    await AudioManager.instance.init();

    // Let the initial fade-in settle (its play fails in the test env and
    // is caught; no fade timer is left running).
    await Future.delayed(const Duration(milliseconds: 300));
    calls.clear();

    // Fade-out starts stepping toward its 1s stop...
    await AudioManager.instance.stopBgm();
    // ...and a newer fade (fade-in) takes over almost immediately — the
    // exact shape of a menu/game context switch.
    await Future.delayed(const Duration(milliseconds: 50));
    await AudioManager.instance.startBgm();

    // The old fade-out's stop used to land here, after the takeover.
    await Future.delayed(const Duration(milliseconds: 1300));

    // Sanity: the fade-out branch really started stepping.
    expect(
      calls.where((m) => m == 'setVolume'),
      isNotEmpty,
      reason: 'fade-out branch did not run',
    );

    // Core regression: the superseded fade must never stop the player.
    expect(
      calls,
      isNot(contains('stop')),
      reason: 'stale fade-out stop landed after a newer fade took over',
    );
  });

  test('uninterrupted fade-out still completes with exactly one stop', () async {
    calls.clear();

    // No newer fade takes over: the fade-out must run its full course and
    // stop the player exactly once (the guard must not break normal fades).
    await AudioManager.instance.stopBgm();
    await Future.delayed(const Duration(milliseconds: 1300));

    expect(
      calls.where((m) => m == 'stop'),
      hasLength(1),
      reason: 'uninterrupted fade-out must still stop the player once',
    );
  });

  test('dispose during a fade stops all further player calls', () async {
    // Start a fresh fade (fade-in after the previous fade-out).
    await AudioManager.instance.startBgm();
    AudioManager.instance.dispose();

    // Let the players' own dispose chains (stop/release) drain out of the
    // recording; only what happens AFTER this point is fade activity.
    await Future.delayed(const Duration(milliseconds: 300));
    calls.clear();
    await Future.delayed(const Duration(milliseconds: 1200));

    expect(calls, isEmpty, reason: 'fade touched the players after dispose');
  });
}

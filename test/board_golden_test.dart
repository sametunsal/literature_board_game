import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:literature_board_game/presentation/widgets/board/board_layout.dart';
import 'package:literature_board_game/providers/game_notifier.dart';
import 'package:literature_board_game/core/utils/board_layout_config.dart';
import 'package:literature_board_game/models/player.dart';
import 'package:literature_board_game/data/board_config.dart';

/// Full-screen golden of the landscape (10:7) board at 1920x1080.
///
/// Text renders with the test-environment placeholder font, so this golden
/// pins geometry, tile topology, colour strips, and the centre area — not
/// typography.
///
/// Font handling is deliberate — every straightforward option fails:
/// - With `allowRuntimeFetching = false` (the flutter_test_config default),
///   google_fonts rethrows each unbundled-font load as an unhandled async
///   error that `tester.takeException` cannot drain, failing the test.
/// - Awaiting `GoogleFonts.pendingFonts()` inside `tester.runAsync`
///   deadlocks: the font futures live in the fake-async test zone and only
///   advance via `pump()`, which never runs while runAsync awaits. That
///   previously hung this test for its full 10-minute timeout.
/// - The real network client (`HttpOverrides.global = null`) leaves
///   happy-eyeballs socket stagger timers pending in the fake-async zone,
///   tripping the end-of-test pending-timer assertion.
/// So fetching is allowed but routed to [_NeverCompletingHttpClient]: the
/// font futures stay harmlessly pending for the lifetime of the test — no
/// errors, no timers, no network, deterministic placeholder glyphs.
void main() {
  testWidgets('BoardLayout landscape full screen golden', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    GoogleFonts.config.allowRuntimeFetching = true;
    HttpOverrides.global = _NeverCompletingHttpOverrides();
    addTearDown(() {
      GoogleFonts.config.allowRuntimeFetching = false;
      HttpOverrides.global = null;
    });

    // Without this mock the font cache probe throws MissingPluginException
    // (an unhandled async error) before ever reaching HTTP.
    final fontCacheDir = Directory.systemTemp.createTempSync(
      'literature_board_game_google_fonts_',
    );
    const pathProviderChannel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      pathProviderChannel,
      (methodCall) async {
        if (methodCall.method == 'getApplicationSupportDirectory') {
          return fontCacheDir.path;
        }
        return null;
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        pathProviderChannel,
        null,
      );
      if (fontCacheDir.existsSync()) {
        fontCacheDir.deleteSync(recursive: true);
      }
    });

    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final config = BoardLayoutConfig(screenWidth: 1920, screenHeight: 1080);

    final mockState = GameState(
      players: const [
        Player(id: 'p1', name: 'Oyuncu 1', color: Colors.blue, iconIndex: 0),
        Player(id: 'p2', name: 'Oyuncu 2', color: Colors.red, iconIndex: 1),
      ],
      tiles: BoardConfig.tiles,
      currentPlayerIndex: 0,
    );

    final confettiController = ConfettiController();
    addTearDown(confettiController.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: const Color(0xFF1A1A2E), // Koyu tema arka planı
            body: BoardLayout(
              state: mockState,
              layout: config,
              isDarkMode: true,
              confettiController: confettiController,
              onQuestionConfirm: () {},
              onQuestionCancel: () {},
            ),
          ),
        ),
      ),
    );

    // Giriş animasyonu ilk karede başlar (fadeIn/scale); sonraki pump'lar
    // animasyonu tamamlar. Bunlar olmadan golden yalnızca ilk kareyi yakalar.
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 3));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/board_layout_screen.png'),
    );
  });
}

class _NeverCompletingHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _NeverCompletingHttpClient();
}

/// An [HttpClient] whose requests never complete.
///
/// google_fonts must never observe a *completed* font fetch in this test:
/// success would register real glyphs (nondeterministic golden), and failure
/// is rethrown by google_fonts as an unhandled async error. A request that
/// hangs forever creates no sockets, no timers, and no errors.
class _NeverCompletingHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.isMethod) {
      return Completer<HttpClientRequest>().future;
    }
    return null;
  }
}

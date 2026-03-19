import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:flutter/services.dart';

import 'package:literature_board_game/presentation/widgets/board/board_layout.dart';
import 'package:literature_board_game/providers/game_notifier.dart';
import 'package:literature_board_game/core/utils/board_layout_config.dart';
import 'package:literature_board_game/models/player.dart';
import 'package:literature_board_game/data/board_config.dart';

void main() {
  testWidgets('BoardLayout Isometric Full Screen Golden Test', (WidgetTester tester) async {
    // SharedPreferences test mock
    SharedPreferences.setMockInitialValues({});

    // Mock path_provider for Google Fonts caching
    const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationSupportDirectory') {
        return '.';
      }
      return null;
    });

    // Allow GoogleFonts to fetch over network by overriding the test HTTP client blocker
    HttpOverrides.global = null;
    GoogleFonts.config.allowRuntimeFetching = true;

    // Mobil yatay (landscape) ekranı simüle edelim (örn. 1920x1080)
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Logical sizes according to pixel ratio
    final logicalWidth = 1920.0;
    final logicalHeight = 1080.0;

    final config = BoardLayoutConfig(
      screenWidth: logicalWidth,
      screenHeight: logicalHeight,
    );

    final mockState = GameState(
      players: const [
        Player(id: 'p1', name: 'Oyuncu 1', color: Colors.blue, iconIndex: 0),
        Player(id: 'p2', name: 'Oyuncu 2', color: Colors.red, iconIndex: 1),
      ],
      tiles: BoardConfig.tiles,
      currentPlayerIndex: 0,
    );

    final confettiController = ConfettiController();

    await tester.runAsync(() async {
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

      // Animasyonların (giriş animasyonu vb) tamamlanması için zaman ver.
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(seconds: 3));
      // Give google fonts HTTP requests time to finish
      await Future.delayed(const Duration(seconds: 3));
    });

    // Tüm ekranı golden teste tabi tutalım (tahtanın ekrana nasıl oturduğunu görmek için)
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/isometric_board_screen.png'),
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import 'views/game_view.dart';
import 'providers/game_provider.dart';
import 'providers/tile_provider.dart';
import 'providers/question_provider.dart';
import 'providers/card_provider.dart';
import 'models/player.dart';
import 'models/player_type.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_initialized) return;

      // Oyunu başlat
      ref
          .read(gameProvider.notifier)
          .initializeGame(
            players: _generatePlayers(),
            tiles: generateTiles(),
            sansCards: generateSansCards(),
            kaderCards: generateKaderCards(),
          );

      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ÖNEMLİ: Sadece tek bir MaterialApp döndürüyoruz.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Edebiyat Oyunu',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.brown,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      // Home widget'ını bir Consumer ile sarmalıyoruz
      // Böylece yükleme durumu değiştiğinde MaterialApp yeniden kurulmaz,
      // sadece içerideki sayfa değişir.
      home: Consumer(
        builder: (context, ref, child) {
          final questionsAsync = ref.watch(questionLoadingProvider);

          // 1. Yükleniyor durumu
          if (questionsAsync.isLoading) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Sorular yükleniyor...',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }

          // 2. Hata durumu
          if (questionsAsync.hasError) {
            return Scaffold(
              body: Center(child: Text('Hata oluştu: ${questionsAsync.error}')),
            );
          }

          // 3. Oyun ekranı
          return const GameView();
        },
      ),
    );
  }
}

/// HELPERS

List<Player> _generatePlayers() {
  return [
    // Human player
    Player(
      id: const Uuid().v4(),
      name: 'Oyuncu 1',
      color: '#FF5722',
      stars: 150,
      position: 1,
      type: PlayerType.human,
    ),
    // Bot players
    Player(
      id: const Uuid().v4(),
      name: 'Oyuncu 2',
      color: '#2196F3',
      stars: 150,
      position: 1,
      type: PlayerType.bot,
    ),
    Player(
      id: const Uuid().v4(),
      name: 'Oyuncu 3',
      color: '#4CAF50',
      stars: 150,
      position: 1,
      type: PlayerType.bot,
    ),
    Player(
      id: const Uuid().v4(),
      name: 'Oyuncu 4',
      color: '#FFEB3B',
      stars: 150,
      position: 1,
      type: PlayerType.bot,
    ),
  ];
}

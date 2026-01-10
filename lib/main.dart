import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/game_notifier.dart';
import 'models/game_enums.dart';
import 'widgets/splash_screen.dart';
import 'widgets/board_view.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B4721),
          brightness: Brightness.light,
        ),
      ),
      home: _getHome(state.phase),
    );
  }

  Widget _getHome(GamePhase phase) {
    switch (phase) {
      case GamePhase.setup:
        // Show splash first, it will navigate to SetupScreen
        return const SplashScreen();
      case GamePhase.rollingForOrder:
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [Color(0xFF1B4721), Color(0xFF0D2818)],
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFD4AF37)),
                  SizedBox(height: 16),
                  Text(
                    "Sıra belirleniyor...",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        );
      default:
        return const BoardView();
    }
  }
}

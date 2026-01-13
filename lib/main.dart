import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/game_notifier.dart';
import 'providers/theme_notifier.dart';
import 'models/game_enums.dart';
import 'widgets/splash_screen.dart';
import 'widgets/board_view.dart';
import 'core/theme/game_theme.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    final themeState = ref.watch(themeProvider);

    return MaterialApp(
      title: 'EDEBİNA',
      debugShowCheckedModeBanner: false,
      theme: GameTheme.buildThemeData(themeState.isDarkMode),
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
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  GameTheme.tableHighlightColor,
                  GameTheme.tableBackgroundColor,
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: GameTheme.goldAccent),
                  const SizedBox(height: 16),
                  Text(
                    "Sıra belirleniyor...",
                    style: TextStyle(color: GameTheme.textDark, fontSize: 16),
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

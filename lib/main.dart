import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/game_notifier.dart';
import 'models/game_enums.dart';
import 'widgets/setup_screen.dart';
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
      home: _getHome(state.phase),
    );
  }

  Widget _getHome(GamePhase phase) {
    if (phase == GamePhase.setup) return const SetupScreen();
    // Keep the loading screen for better UX even if user didn't explicitly ask for it in the simplified snippet
    if (phase == GamePhase.rollingForOrder)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return const BoardView();
  }
}

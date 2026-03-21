import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/game_notifier.dart';
import 'providers/theme_notifier.dart';
import 'providers/app_bootstrap.dart';
import 'models/game_enums.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/widgets/board_view.dart';
import 'core/theme/game_theme.dart';

import 'core/managers/audio_manager.dart';
import 'core/utils/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Audio Manager (starts BGM)
  await AudioManager.instance.init();

  // Enforce Portrait Mode on Startup
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runBootstrap();
    });
  }

  Future<void> _runBootstrap() async {
    try {
      await ref.read(appBootstrapProvider.future);
      safePrint('Bootstrap completed successfully');
    } catch (e) {
      safePrint('Bootstrap error (non-blocking): $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp(
      title: 'EDEBİNA',
      debugShowCheckedModeBanner: false,
      theme: GameTheme.buildThemeData(themeState.isDarkMode),
      home: const _HomeRouter(),
    );
  }
}

/// Routes to appropriate screen based on game phase
class _HomeRouter extends ConsumerWidget {
  const _HomeRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    final themeState = ref.watch(themeProvider);
    final tokens = themeState.tokens;

    switch (state.phase) {
      case GamePhase.setup:
        return const SplashScreen();
      case GamePhase.rollingForOrder:
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [tokens.backgroundHighlight, tokens.background],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: tokens.accent),
                  const SizedBox(height: 16),
                  Text(
                    "Sıra belirleniyor...",
                    style: TextStyle(color: tokens.textPrimary, fontSize: 16),
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

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'providers/game_notifier.dart';
import 'providers/theme_notifier.dart';
import 'providers/app_bootstrap.dart';
import 'models/game_enums.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/widgets/board_view.dart';
import 'core/theme/game_theme.dart';

/// Tracks if Firebase was initialized successfully
bool _firebaseInitialized = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling - don't crash if it fails
  await _initializeFirebase();

  runApp(const ProviderScope(child: MyApp()));
}

/// Safely initialize Firebase - returns silently on failure
Future<void> _initializeFirebase() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    _firebaseInitialized = true;
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    _firebaseInitialized = false;
    debugPrint('Firebase initialization failed (app will continue): $e');
    // Don't rethrow - let the app run without Firebase
  }
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
    // Only run bootstrap if Firebase initialized successfully
    if (_firebaseInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _runBootstrap();
      });
    }
  }

  Future<void> _runBootstrap() async {
    try {
      await ref.read(appBootstrapProvider.future);
      debugPrint('Bootstrap completed successfully');
    } catch (e) {
      debugPrint('Bootstrap error (non-blocking): $e');
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

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_providers.dart';
import 'repository_providers.dart';

/// Bootstrap provider that handles post-Firebase initialization tasks.
/// Firebase is already initialized in main() before this runs.
import 'package:literature_board_game/core/utils/logger.dart';

final appBootstrapProvider = FutureProvider<void>((ref) async {
  safePrint('[AppBootstrap] Starting bootstrap...');

  try {
    // 1. Ensure anonymous sign-in and create/update user profile
    final ensureSignedIn = ref.read(ensureSignedInAnonymouslyProvider);
    await ensureSignedIn();
    safePrint('[AppBootstrap] ✅ Anonymous sign-in completed');
  } catch (e) {
    safePrint('[AppBootstrap] ⚠️ Bootstrap auth error: $e');
    // Don't rethrow - let app continue without auth
  }

  try {
    // 2. Load questions from Firestore (auto-seeds if empty)
    safePrint('[AppBootstrap] Loading questions from Firestore...');
    final questionRepository = ref.read(questionRepositoryProvider);
    await questionRepository.loadQuestions();
    safePrint('[AppBootstrap] ✅ Questions loaded/seeded successfully');
  } catch (e, stackTrace) {
    safePrint('[AppBootstrap] ❌ Questions loading error: $e');
    safePrint('[AppBootstrap] Stack trace:\n$stackTrace');
    // Don't rethrow - let app continue without questions (will retry later)
  }

  safePrint('[AppBootstrap] ✅ Bootstrap completed');
});

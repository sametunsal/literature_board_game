import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_providers.dart';
import 'repository_providers.dart';

/// Bootstrap provider that handles post-Firebase initialization tasks.
/// Firebase is already initialized in main() before this runs.
final appBootstrapProvider = FutureProvider<void>((ref) async {
  debugPrint('[AppBootstrap] Starting bootstrap...');

  try {
    // 1. Ensure anonymous sign-in and create/update user profile
    final ensureSignedIn = ref.read(ensureSignedInAnonymouslyProvider);
    await ensureSignedIn();
    debugPrint('[AppBootstrap] ✅ Anonymous sign-in completed');
  } catch (e) {
    debugPrint('[AppBootstrap] ⚠️ Bootstrap auth error: $e');
    // Don't rethrow - let app continue without auth
  }

  try {
    // 2. Load questions from Firestore (auto-seeds if empty)
    debugPrint('[AppBootstrap] Loading questions from Firestore...');
    final questionRepository = ref.read(questionRepositoryProvider);
    await questionRepository.loadQuestions();
    debugPrint('[AppBootstrap] ✅ Questions loaded/seeded successfully');
  } catch (e, stackTrace) {
    debugPrint('[AppBootstrap] ❌ Questions loading error: $e');
    debugPrint('[AppBootstrap] Stack trace:\n$stackTrace');
    // Don't rethrow - let app continue without questions (will retry later)
  }

  debugPrint('[AppBootstrap] ✅ Bootstrap completed');
});

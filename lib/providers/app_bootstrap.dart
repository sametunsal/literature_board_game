import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_providers.dart';

/// Bootstrap provider that handles post-Firebase initialization tasks.
/// Firebase is already initialized in main() before this runs.
final appBootstrapProvider = FutureProvider<void>((ref) async {
  try {
    // Ensure anonymous sign-in and create/update user profile
    final ensureSignedIn = ref.read(ensureSignedInAnonymouslyProvider);
    await ensureSignedIn();
    debugPrint('Anonymous sign-in completed');
  } catch (e) {
    debugPrint('Bootstrap auth error: $e');
    // Don't rethrow - let app continue without auth
  }
});

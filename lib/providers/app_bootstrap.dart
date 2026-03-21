/// Bootstrap provider that handles post-initialization tasks.
/// Loads questions from local JSON assets.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'repository_providers.dart';
import 'package:literature_board_game/core/utils/logger.dart';

final appBootstrapProvider = FutureProvider<void>((ref) async {
  safePrint('[AppBootstrap] Starting bootstrap...');

  try {
    safePrint('[AppBootstrap] Loading questions from local JSON...');
    final questionRepository = ref.read(questionRepositoryProvider);
    await questionRepository.loadQuestions();
    safePrint('[AppBootstrap] Questions loaded successfully');
  } catch (e, stackTrace) {
    safePrint('[AppBootstrap] Questions loading error: $e');
    safePrint('[AppBootstrap] Stack trace:\n$stackTrace');
  }

  safePrint('[AppBootstrap] Bootstrap completed');
});

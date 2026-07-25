import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards against referencing audio assets that do not ship.
///
/// `AudioManager.playSfx` swallows playback failures in a try/catch, so a
/// reference to a missing file is silent at runtime: no crash, no failing test,
/// just a sound that never plays. This scan is what catches it. It is the
/// regression guard for `audio/star_collect.wav`, which was referenced by
/// MovementService for the pass-start bonus but was never present in
/// `assets/audio/`.
void main() {
  group('audio asset references', () {
    // Matches the asset-relative literals passed to playSfx and listed in the
    // BGM playlists, e.g. 'audio/correct.wav', 'audio/menu_bg1.mp3'.
    final audioRefPattern = RegExp(r'''['"](audio/[\w\-.]+\.(?:wav|mp3))['"]''');

    // Comments legitimately mention asset paths as examples or as history
    // ("was audio/star_collect.wav"). Only real code should be checked, so
    // strip line and block comments first.
    final lineComment = RegExp(r'//.*');
    final blockComment = RegExp(r'/\*.*?\*/', dotAll: true);

    /// Every distinct `audio/...` literal in lib/ code, with the file holding it.
    Map<String, Set<String>> collectReferences() {
      final references = <String, Set<String>>{};
      final dartFiles = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));

      for (final file in dartFiles) {
        final code = file
            .readAsStringSync()
            .replaceAll(blockComment, '')
            .replaceAll(lineComment, '');
        for (final match in audioRefPattern.allMatches(code)) {
          references
              .putIfAbsent(match.group(1)!, () => <String>{})
              .add(file.path);
        }
      }
      return references;
    }

    test('every audio asset referenced in lib/ exists in assets/', () {
      final references = collectReferences();

      // Sanity check: if this scan silently matched nothing, the test below
      // would pass vacuously and guard nothing at all.
      expect(
        references,
        isNotEmpty,
        reason: 'Found no audio references in lib/ — the scan is broken.',
      );

      final missing = <String>[];
      references.forEach((asset, sourceFiles) {
        if (!File('assets/$asset').existsSync()) {
          missing.add('assets/$asset referenced by ${sourceFiles.join(', ')}');
        }
      });

      expect(
        missing,
        isEmpty,
        reason:
            'Referenced audio files are missing from assets/. playSfx fails '
            'silently on these:\n${missing.join('\n')}',
      );
    });
  });
}

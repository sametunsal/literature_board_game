import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:literature_board_game/models/book_level.dart';
import 'package:literature_board_game/presentation/widgets/publication_badge.dart';

/// The badge has to say two things at once: *which publication step* this is
/// (Telif / Baskı / Cilt) and *who received it*. Losing either half is the
/// failure mode — a badge that only shows the level leaves the board
/// unreadable in a four-player game, and one that only shows the owner colour
/// erases the progression the whole economy is built on.
void main() {
  const levels = {
    BookLevel.telif: 'T',
    BookLevel.baski: 'B',
    BookLevel.cilt: 'C',
  };

  Widget app(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  for (final entry in levels.entries) {
    testWidgets('${entry.key.name} badge stamps ${entry.value}', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          PublicationBadge(level: entry.key, ownerColor: Colors.red, size: 34),
        ),
      );

      expect(find.text(entry.value), findsOneWidget);
      expect(tester.getSize(find.byType(PublicationBadge)), const Size(34, 34));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('each level keeps its own enamel so T/B/C stay distinguishable', (
    tester,
  ) async {
    final enamels = <Color>{};
    for (final level in levels.keys) {
      final style = PublicationLevelStyle.forLevel(level);
      expect(style, isNotNull, reason: '$level must have an enamel');
      enamels.add(style!.enamelDark);
    }
    expect(enamels, hasLength(levels.length));
  });

  testWidgets('an unpublished book falls back to the label it is given', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        const PublicationBadge(
          level: BookLevel.none,
          ownerColor: Colors.blue,
          size: 11,
          fallbackLabel: '3',
        ),
      ),
    );

    expect(PublicationLevelStyle.forLevel(BookLevel.none), isNull);
    expect(find.text('3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('badge renders across the whole size range it is used at', (
    tester,
  ) async {
    // 11dp is the tile strip badge, 34dp the acquisition toast; the values in
    // between guard against a fraction collapsing to a zero-width stroke.
    for (final size in const [11.0, 14.0, 22.0, 34.0]) {
      await tester.pumpWidget(
        app(
          PublicationBadge(
            level: BookLevel.cilt,
            ownerColor: Colors.green,
            size: size,
          ),
        ),
      );

      final box = tester.getRect(find.byType(PublicationBadge));
      expect(box.size, Size(size, size));

      // The letter must stay inside the medallion at every scale.
      final letter = tester.getRect(find.text('C'));
      expect(letter.left, greaterThanOrEqualTo(box.left));
      expect(letter.right, lessThanOrEqualTo(box.right));
      expect(letter.top, greaterThanOrEqualTo(box.top));
      expect(letter.bottom, lessThanOrEqualTo(box.bottom));
      expect(tester.takeException(), isNull, reason: 'size $size');
    }
  });

  testWidgets('a degenerate size paints nothing rather than throwing', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        const PublicationBadge(
          level: BookLevel.telif,
          ownerColor: Colors.red,
          size: 0,
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}

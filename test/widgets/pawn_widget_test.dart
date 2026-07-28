import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/models/player.dart';
import 'package:literature_board_game/presentation/widgets/pawn_widget.dart';

/// PawnManager positions every pawn assuming its layout box is exactly
/// size x size — the figurine (plinth, cast shadow, halo, bob, hop) must paint
/// its depth *inside* that box, or beyond it without inflating it. These tests
/// pin that contract, the four-figurine identity split, and the rule that the
/// cast shadow stays on the board while the body leaves it.
void main() {
  const player = Player(
    id: 'p1',
    name: 'Oyuncu 1',
    color: Colors.red,
    iconIndex: 0,
  );

  Widget app({
    required bool isCurrentTurn,
    double size = 20,
    int position = 0,
    PawnFigurine? figurine,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: PawnWidget(
            player: player.copyWith(position: position),
            size: size,
            isActive: isCurrentTurn,
            isCurrentTurn: isCurrentTurn,
            figurine: figurine,
          ),
        ),
      ),
    );
  }

  Finder body() => find.byKey(PawnWidget.bodyKey);

  testWidgets('layout box is exactly size x size', (tester) async {
    await tester.pumpWidget(app(isCurrentTurn: false));
    await tester.pump();

    expect(tester.getSize(find.byType(PawnWidget)), const Size(20, 20));
  });

  testWidgets('current-turn glow does not change the layout size', (
    tester,
  ) async {
    await tester.pumpWidget(app(isCurrentTurn: true));
    await tester.pump();

    expect(tester.getSize(find.byType(PawnWidget)), const Size(20, 20));
  });

  testWidgets('layout size holds across the board size range', (tester) async {
    for (final size in const [8.0, 14.0, 20.0, 48.0, 120.0]) {
      await tester.pumpWidget(app(isCurrentTurn: true, size: size));
      await tester.pump(const Duration(milliseconds: 400));

      expect(tester.getSize(find.byType(PawnWidget)), Size(size, size));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('idle pawn paints the shadow and the figurine only', (
    tester,
  ) async {
    await tester.pumpWidget(app(isCurrentTurn: false));
    await tester.pump();

    // Ground shadow + figurine. The glow painter is only mounted for the
    // active player.
    final painters = find.descendant(
      of: find.byType(PawnWidget),
      matching: find.byType(CustomPaint),
    );
    expect(painters, findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('current turn adds a glow painter behind the piece', (
    tester,
  ) async {
    await tester.pumpWidget(app(isCurrentTurn: true));
    await tester.pump();

    expect(
      find.descendant(
        of: find.byType(PawnWidget),
        matching: find.byType(CustomPaint),
      ),
      findsNWidgets(3),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('active pawn bobs: the body lifts off the board', (
    tester,
  ) async {
    await tester.pumpWidget(app(isCurrentTurn: true, size: 200));
    await tester.pump();

    final atRest = tester.getTopLeft(body()).dy;
    // A quarter into the alive cycle the piece is partway up its bob.
    await tester.pump(const Duration(milliseconds: 650));
    final lifted = tester.getTopLeft(body()).dy;

    expect(lifted, lessThan(atRest));
    expect(tester.takeException(), isNull);
  });

  testWidgets('inactive pawn stays perfectly still', (tester) async {
    await tester.pumpWidget(app(isCurrentTurn: false, size: 200));
    await tester.pump();

    final first = tester.getTopLeft(body());
    await tester.pump(const Duration(milliseconds: 650));
    await tester.pump(const Duration(milliseconds: 1300));

    expect(tester.getTopLeft(body()), first);
    expect(tester.takeException(), isNull);
  });

  testWidgets('changing tile plays a hop that settles back down', (
    tester,
  ) async {
    await tester.pumpWidget(app(isCurrentTurn: false, size: 200));
    await tester.pump();
    final grounded = tester.getTopLeft(body()).dy;

    // Moving to another tile is what PawnManager does on a roll; the piece
    // must leave the board and land again, not just slide.
    await tester.pumpWidget(app(isCurrentTurn: false, size: 200, position: 3));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    final midHop = tester.getTopLeft(body()).dy;

    expect(midHop, lessThan(grounded));

    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.getTopLeft(body()).dy, closeTo(grounded, 0.5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the hop squashes the body about its contact point', (
    tester,
  ) async {
    await tester.pumpWidget(app(isCurrentTurn: false, size: 200));
    await tester.pump();
    final resting = tester.getRect(body());

    await tester.pumpWidget(app(isCurrentTurn: false, size: 200, position: 5));
    await tester.pump();
    // Landing frame: the piece compresses as it takes its own weight.
    await tester.pump(const Duration(milliseconds: 340));
    final landing = tester.getRect(body());

    expect(landing.height, lessThan(resting.height));
    expect(landing.width, greaterThan(resting.width));

    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.getRect(body()).height, closeTo(resting.height, 0.5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('every figurine renders at every board size', (tester) async {
    for (final figurine in PawnFigurine.values) {
      for (final size in const [8.0, 20.0, 64.0]) {
        await tester.pumpWidget(
          app(isCurrentTurn: true, size: size, figurine: figurine),
        );
        await tester.pump(const Duration(milliseconds: 300));

        expect(
          tester.getSize(find.byType(PawnWidget)),
          Size(size, size),
          reason: '$figurine at $size',
        );
        expect(tester.takeException(), isNull, reason: '$figurine at $size');
      }
    }
  });

  testWidgets('there are four distinct figurine identities', (tester) async {
    expect(PawnFigurine.values, hasLength(4));
    expect(
      PawnFigurine.values.toSet(),
      containsAll(<PawnFigurine>[
        PawnFigurine.book,
        PawnFigurine.quill,
        PawnFigurine.typewriter,
        PawnFigurine.lantern,
      ]),
    );
  });

  testWidgets('figurine falls back to the icon index and cycles', (
    tester,
  ) async {
    PawnFigurine resolve(int iconIndex) => PawnWidget(
      player: player.copyWith(iconIndex: iconIndex),
      size: 20,
    ).resolvedFigurine;

    expect(resolve(0), PawnFigurine.book);
    expect(resolve(1), PawnFigurine.quill);
    expect(resolve(2), PawnFigurine.typewriter);
    expect(resolve(3), PawnFigurine.lantern);
    // Players may pick any of the ten avatar icons; the piece must still
    // resolve rather than throw.
    expect(resolve(9), PawnFigurine.quill);
  });

  testWidgets('an explicit figurine overrides the icon index', (tester) async {
    expect(
      PawnWidget(
        player: player.copyWith(iconIndex: 0),
        size: 20,
        figurine: PawnFigurine.lantern,
      ).resolvedFigurine,
      PawnFigurine.lantern,
    );
  });

  testWidgets('palette keeps the player colour as the enamel mid-tone', (
    tester,
  ) async {
    final palette = PawnPalette.from(Colors.red);

    expect(palette.base, Colors.red);
    // Lighting shades must stay ordered light → base → deep → rim so every
    // enamel surface on the piece reads as one lit material.
    double lightness(Color c) => HSLColor.fromColor(c).lightness;
    expect(lightness(palette.sheen), greaterThan(lightness(palette.base)));
    expect(lightness(palette.deep), lessThan(lightness(palette.base)));
    expect(lightness(palette.rim), lessThan(lightness(palette.deep)));
  });

  testWidgets('tiny pawns still render without exceptions', (tester) async {
    await tester.pumpWidget(app(isCurrentTurn: true, size: 6));
    await tester.pump(const Duration(milliseconds: 650));

    expect(tester.getSize(find.byType(PawnWidget)), const Size(6, 6));
    expect(tester.takeException(), isNull);
  });

  testWidgets('animated pawn disposes its tickers cleanly', (tester) async {
    await tester.pumpWidget(app(isCurrentTurn: true, size: 60));
    await tester.pump(const Duration(milliseconds: 400));

    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
}

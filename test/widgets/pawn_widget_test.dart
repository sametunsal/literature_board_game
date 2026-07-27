import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/models/player.dart';
import 'package:literature_board_game/presentation/widgets/pawn_widget.dart';

/// PawnManager positions every pawn assuming its layout box is exactly
/// size x size — the extruded token (ground shadow, side wall, halo, bob) must
/// paint its depth *inside* that box, or beyond it without inflating it.
/// These tests pin that contract plus the active/inactive motion split.
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
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: PawnWidget(
            player: player.copyWith(position: position),
            size: size,
            isActive: isCurrentTurn,
            isCurrentTurn: isCurrentTurn,
          ),
        ),
      ),
    );
  }

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

  testWidgets('token body is painted in a single CustomPaint pass', (
    tester,
  ) async {
    await tester.pumpWidget(app(isCurrentTurn: false));
    await tester.pump();

    // Idle pawn: exactly one painter (the token). The glow painter is only
    // mounted for the active player.
    final painters = find.descendant(
      of: find.byType(PawnWidget),
      matching: find.byType(CustomPaint),
    );
    expect(painters, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('current turn adds a glow painter behind the token', (
    tester,
  ) async {
    await tester.pumpWidget(app(isCurrentTurn: true));
    await tester.pump();

    expect(
      find.descendant(
        of: find.byType(PawnWidget),
        matching: find.byType(CustomPaint),
      ),
      findsNWidgets(2),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('active pawn bobs: the glyph rides the lifting token', (
    tester,
  ) async {
    await tester.pumpWidget(app(isCurrentTurn: true, size: 200));
    await tester.pump();

    final atRest = tester.getTopLeft(find.byType(Icon)).dy;
    // A quarter into the alive cycle the token is partway up its bob.
    await tester.pump(const Duration(milliseconds: 650));
    final lifted = tester.getTopLeft(find.byType(Icon)).dy;

    expect(lifted, lessThan(atRest));
    expect(tester.takeException(), isNull);
  });

  testWidgets('inactive pawn stays perfectly still', (tester) async {
    await tester.pumpWidget(app(isCurrentTurn: false, size: 200));
    await tester.pump();

    final first = tester.getTopLeft(find.byType(Icon));
    await tester.pump(const Duration(milliseconds: 650));
    await tester.pump(const Duration(milliseconds: 1300));

    expect(tester.getTopLeft(find.byType(Icon)), first);
    expect(tester.takeException(), isNull);
  });

  testWidgets('changing tile plays a hop that settles back down', (
    tester,
  ) async {
    await tester.pumpWidget(app(isCurrentTurn: false, size: 200));
    await tester.pump();
    final grounded = tester.getTopLeft(find.byType(Icon)).dy;

    // Moving to another tile is what PawnManager does on a roll; the pawn
    // must leave the board and land again, not just slide.
    await tester.pumpWidget(app(isCurrentTurn: false, size: 200, position: 3));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    final midHop = tester.getTopLeft(find.byType(Icon)).dy;

    expect(midHop, lessThan(grounded));

    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.getTopLeft(find.byType(Icon)).dy, closeTo(grounded, 0.5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('player icon glyph is rendered inside the token', (
    tester,
  ) async {
    await tester.pumpWidget(app(isCurrentTurn: false));
    await tester.pump();

    final iconFinder = find.descendant(
      of: find.byType(PawnWidget),
      matching: find.byType(Icon),
    );
    expect(iconFinder, findsOneWidget);
    expect(tester.widget<Icon>(iconFinder).color, Colors.white);
  });

  testWidgets('palette keeps the player colour as the cap mid-tone', (
    tester,
  ) async {
    final palette = PawnPalette.from(Colors.red);

    expect(palette.base, Colors.red);
    // Lighting shades must stay ordered light → base → deep → rim so the
    // token always reads as one lit material.
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

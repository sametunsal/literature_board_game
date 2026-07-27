import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/models/player.dart';
import 'package:literature_board_game/presentation/widgets/pawn_widget.dart';

/// PawnManager positions every pawn assuming its layout box is exactly
/// size x size — decorative layers (glow, ground shadow, sheen) must paint
/// outside without inflating layout. These tests pin that contract for the
/// layered token design.
void main() {
  const player = Player(
    id: 'p1',
    name: 'Oyuncu 1',
    color: Colors.red,
    iconIndex: 0,
  );

  Widget app({required bool isCurrentTurn, double size = 20}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: PawnWidget(
            player: player,
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

  testWidgets('palette keeps the player colour as the dome mid-tone', (
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
    await tester.pumpWidget(app(isCurrentTurn: true, size: 8));
    await tester.pump();

    expect(tester.getSize(find.byType(PawnWidget)), const Size(8, 8));
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
}

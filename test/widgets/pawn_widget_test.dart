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

  testWidgets('token body renders with a radial gradient and rim border', (
    tester,
  ) async {
    await tester.pumpWidget(app(isCurrentTurn: false));
    await tester.pump();

    final bodyFinder = find.byWidgetPredicate((widget) {
      if (widget is! Container) return false;
      final decoration = widget.decoration;
      return decoration is BoxDecoration &&
          decoration.shape == BoxShape.circle &&
          decoration.gradient is RadialGradient &&
          decoration.border != null;
    });
    expect(bodyFinder, findsOneWidget);
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

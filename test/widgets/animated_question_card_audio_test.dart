import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/core/managers/audio_manager.dart';
import 'package:literature_board_game/models/game_enums.dart';
import 'package:literature_board_game/models/question.dart';
import 'package:literature_board_game/presentation/widgets/animated_question_card.dart';

/// Answer feedback audio for the live question card.
///
/// The card was silent before this: the only correct/wrong SFX in the codebase
/// lived in `modern_question_dialog.dart`, which is dead code. These tests pin
/// the wiring — which sound fires, when it fires, and that it stays behind the
/// sound-enabled gate.
void main() {
  const question = Question(
    text: 'Soru metni',
    options: ['Birinci', 'Ikinci', 'Ucuncu', 'Dorduncu'],
    correctIndex: 1,
    category: QuestionCategory.edebiyatAkimlari,
  );

  /// SFX assets observed through AudioManager's test seam, in fire order.
  late List<String> firedSfx;

  setUp(() {
    firedSfx = <String>[];
    AudioManager.debugSfxHandler = firedSfx.add;
  });

  tearDown(() {
    AudioManager.debugSfxHandler = null;
    AudioManager.instance.toggleSound(true);
  });

  Future<void> pumpCard(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedQuestionCard(question: question, onAnswer: (_) {}),
        ),
      ),
    );
    // Entrance animation is scheduled 80ms out.
    await tester.pump(const Duration(milliseconds: 500));
  }

  /// Taps an option and advances to just past the 900ms reveal.
  Future<void> answerAndReveal(WidgetTester tester, String optionLabel) async {
    await tester.tap(find.text(optionLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 950));
  }

  testWidgets('correct answer plays the success sting', (tester) async {
    await pumpCard(tester);

    await answerAndReveal(tester, 'Ikinci');

    expect(firedSfx, ['audio/correct.wav']);

    // Let the pending reveal/callback timers drain.
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('wrong answer plays the wrong sting', (tester) async {
    await pumpCard(tester);

    await answerAndReveal(tester, 'Ucuncu');

    expect(firedSfx, ['audio/wrong.wav']);

    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('no sound fires on tap, only on reveal', (tester) async {
    await pumpCard(tester);

    await tester.tap(find.text('Ikinci'));
    await tester.pump();

    // Selection pulse is running; the option has not turned green yet.
    expect(firedSfx, isEmpty);

    await tester.pump(const Duration(milliseconds: 950));
    expect(firedSfx, ['audio/correct.wav']);

    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('answer sound fires once, and further taps are ignored', (
    tester,
  ) async {
    await pumpCard(tester);

    await answerAndReveal(tester, 'Ikinci');

    // Rebuild repeatedly and try to answer again; the card is already answered.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Ucuncu'), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 950));

    expect(firedSfx, ['audio/correct.wav']);

    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('respects the sound-enabled gate', (tester) async {
    AudioManager.instance.toggleSound(false);
    await pumpCard(tester);

    await answerAndReveal(tester, 'Ikinci');

    expect(firedSfx, isEmpty);

    await tester.pump(const Duration(seconds: 5));
  });
}

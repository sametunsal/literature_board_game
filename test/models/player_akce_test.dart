import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/models/player.dart';

void main() {
  Player makePlayer({int stars = 0}) {
    return Player(
      id: 'p1',
      name: 'Player 1',
      color: Colors.blue,
      iconIndex: 0,
      stars: stars,
    );
  }

  group('Player akce compatibility', () {
    test('akce mirrors stars', () {
      final player = makePlayer(stars: 12);

      expect(player.stars, 12);
      expect(player.akce, 12);
    });

    test('copyWith akce writes to existing stars backing field', () {
      final player = makePlayer(stars: 12);

      final updated = player.copyWith(akce: 20);

      expect(updated.stars, 20);
      expect(updated.akce, 20);
    });

    test('copyWith stars still works for existing gameplay', () {
      final player = makePlayer(stars: 12);

      final updated = player.copyWith(stars: 18);

      expect(updated.stars, 18);
      expect(updated.akce, 18);
    });

    test('withAkce returns a copy with mirrored currency', () {
      final player = makePlayer(stars: 12);

      final updated = player.withAkce(7);

      expect(player.stars, 12);
      expect(updated.stars, 7);
      expect(updated.akce, 7);
    });
  });
}

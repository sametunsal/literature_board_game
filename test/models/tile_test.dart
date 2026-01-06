import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/models/tile.dart';
import 'package:literature_board_game/models/question.dart';

void main() {
  group('Tile Model Tests', () {
    late Tile tile;

    setUp(() {
      tile = const Tile(id: 1, name: 'Test Tile', type: TileType.book);
    });

    group('Tile Creation', () {
      test('should create a tile with basic fields', () {
        expect(tile.id, 1);
        expect(tile.name, 'Test Tile');
        expect(tile.type, TileType.book);
      });

      test('should create a corner tile', () {
        const cornerTile = Tile(
          id: 1,
          name: 'Başlangıç',
          type: TileType.corner,
          cornerEffect: CornerEffect.baslangic,
        );
        expect(cornerTile.type, TileType.corner);
        expect(cornerTile.cornerEffect, CornerEffect.baslangic);
      });

      test('should create a book tile', () {
        const bookTile = Tile(
          id: 2,
          name: 'Test Book',
          type: TileType.book,
          group: 1,
          copyrightFee: 10,
          purchasePrice: 50,
          questionCategory: QuestionCategory.benKimim,
        );
        expect(bookTile.type, TileType.book);
        expect(bookTile.group, 1);
        expect(bookTile.copyrightFee, 10);
        expect(bookTile.purchasePrice, 50);
        expect(bookTile.questionCategory, QuestionCategory.benKimim);
      });

      test('should create a publisher tile', () {
        const publisherTile = Tile(
          id: 3,
          name: 'Test Publisher',
          type: TileType.publisher,
          group: 2,
          copyrightFee: 15,
          purchasePrice: 75,
          questionCategory: QuestionCategory.turkEdebiyatindaIlkler,
        );
        expect(publisherTile.type, TileType.publisher);
        expect(publisherTile.group, 2);
        expect(publisherTile.copyrightFee, 15);
        expect(publisherTile.purchasePrice, 75);
      });

      test('should create a chance tile', () {
        const chanceTile = Tile(id: 4, name: 'Şans', type: TileType.chance);
        expect(chanceTile.type, TileType.chance);
      });

      test('should create a fate tile', () {
        const fateTile = Tile(id: 5, name: 'Kader', type: TileType.fate);
        expect(fateTile.type, TileType.fate);
      });

      test('should create a tax tile', () {
        const taxTile = Tile(
          id: 6,
          name: 'Vergi',
          type: TileType.tax,
          taxType: TaxType.gelirVergisi,
          taxRate: 10,
        );
        expect(taxTile.type, TileType.tax);
        expect(taxTile.taxType, TaxType.gelirVergisi);
        expect(taxTile.taxRate, 10);
      });

      test('should create a special tile', () {
        const specialTile = Tile(
          id: 7,
          name: 'Yazarlık Okulu',
          type: TileType.special,
          specialType: SpecialType.yazarlikOkulu,
          questionCategory: QuestionCategory.edebiyatAkimlari,
        );
        expect(specialTile.type, TileType.special);
        expect(specialTile.specialType, SpecialType.yazarlikOkulu);
      });

      test('should create a tile with owner', () {
        const ownedTile = Tile(
          id: 1,
          name: 'Owned Tile',
          type: TileType.book,
          owner: 'player1',
        );
        expect(ownedTile.owner, 'player1');
      });
    });

    group('TileType Enum', () {
      test('should have corner type', () {
        const cornerTile = Tile(id: 1, name: 'Corner', type: TileType.corner);
        expect(cornerTile.type, TileType.corner);
      });

      test('should have book type', () {
        const bookTile = Tile(id: 1, name: 'Book', type: TileType.book);
        expect(bookTile.type, TileType.book);
      });

      test('should have publisher type', () {
        const publisherTile = Tile(
          id: 1,
          name: 'Publisher',
          type: TileType.publisher,
        );
        expect(publisherTile.type, TileType.publisher);
      });

      test('should have chance type', () {
        const chanceTile = Tile(id: 1, name: 'Chance', type: TileType.chance);
        expect(chanceTile.type, TileType.chance);
      });

      test('should have fate type', () {
        const fateTile = Tile(id: 1, name: 'Fate', type: TileType.fate);
        expect(fateTile.type, TileType.fate);
      });

      test('should have tax type', () {
        const taxTile = Tile(id: 1, name: 'Tax', type: TileType.tax);
        expect(taxTile.type, TileType.tax);
      });

      test('should have special type', () {
        const specialTile = Tile(
          id: 1,
          name: 'Special',
          type: TileType.special,
        );
        expect(specialTile.type, TileType.special);
      });
    });

    group('CornerEffect Enum', () {
      test('should have baslangic effect', () {
        const tile = Tile(
          id: 1,
          name: 'Başlangıç',
          type: TileType.corner,
          cornerEffect: CornerEffect.baslangic,
        );
        expect(tile.cornerEffect, CornerEffect.baslangic);
      });

      test('should have kutuphaneNobeti effect', () {
        const tile = Tile(
          id: 1,
          name: 'Kütüphane Nöbeti',
          type: TileType.corner,
          cornerEffect: CornerEffect.kutuphaneNobeti,
        );
        expect(tile.cornerEffect, CornerEffect.kutuphaneNobeti);
      });

      test('should have imzaGunu effect', () {
        const tile = Tile(
          id: 1,
          name: 'İmza Günü',
          type: TileType.corner,
          cornerEffect: CornerEffect.imzaGunu,
        );
        expect(tile.cornerEffect, CornerEffect.imzaGunu);
      });

      test('should have iflasRiski effect', () {
        const tile = Tile(
          id: 1,
          name: 'İflas Riski',
          type: TileType.corner,
          cornerEffect: CornerEffect.iflasRiski,
        );
        expect(tile.cornerEffect, CornerEffect.iflasRiski);
      });
    });

    group('TaxType Enum', () {
      test('should have gelirVergisi type', () {
        const tile = Tile(
          id: 1,
          name: 'Gelir Vergisi',
          type: TileType.tax,
          taxType: TaxType.gelirVergisi,
        );
        expect(tile.taxType, TaxType.gelirVergisi);
      });

      test('should have yazarlikVergisi type', () {
        const tile = Tile(
          id: 1,
          name: 'Yazarlık Vergisi',
          type: TileType.tax,
          taxType: TaxType.yazarlikVergisi,
        );
        expect(tile.taxType, TaxType.yazarlikVergisi);
      });
    });

    group('SpecialType Enum', () {
      test('should have yazarlikOkulu type', () {
        const tile = Tile(
          id: 1,
          name: 'Yazarlık Okulu',
          type: TileType.special,
          specialType: SpecialType.yazarlikOkulu,
        );
        expect(tile.specialType, SpecialType.yazarlikOkulu);
      });

      test('should have deEgitimVakfi type', () {
        const tile = Tile(
          id: 1,
          name: 'DE Eğitim Vakfı',
          type: TileType.special,
          specialType: SpecialType.deEgitimVakfi,
        );
        expect(tile.specialType, SpecialType.deEgitimVakfi);
      });
    });

    group('Tile Type Checkers', () {
      test('isCorner should return true for corner tiles', () {
        const cornerTile = Tile(id: 1, name: 'Corner', type: TileType.corner);
        expect(cornerTile.isCorner, isTrue);
        expect(cornerTile.isBook, isFalse);
        expect(cornerTile.isPublisher, isFalse);
      });

      test('isBook should return true for book tiles', () {
        const bookTile = Tile(id: 1, name: 'Book', type: TileType.book);
        expect(bookTile.isBook, isTrue);
        expect(bookTile.isCorner, isFalse);
        expect(bookTile.isPublisher, isFalse);
      });

      test('isPublisher should return true for publisher tiles', () {
        const publisherTile = Tile(
          id: 1,
          name: 'Publisher',
          type: TileType.publisher,
        );
        expect(publisherTile.isPublisher, isTrue);
        expect(publisherTile.isBook, isFalse);
        expect(publisherTile.isCorner, isFalse);
      });

      test('isChance should return true for chance tiles', () {
        const chanceTile = Tile(id: 1, name: 'Chance', type: TileType.chance);
        expect(chanceTile.isChance, isTrue);
        expect(chanceTile.isFate, isFalse);
      });

      test('isFate should return true for fate tiles', () {
        const fateTile = Tile(id: 1, name: 'Fate', type: TileType.fate);
        expect(fateTile.isFate, isTrue);
        expect(fateTile.isChance, isFalse);
      });

      test('isTax should return true for tax tiles', () {
        const taxTile = Tile(id: 1, name: 'Tax', type: TileType.tax);
        expect(taxTile.isTax, isTrue);
        expect(taxTile.isSpecial, isFalse);
      });

      test('isSpecial should return true for special tiles', () {
        const specialTile = Tile(
          id: 1,
          name: 'Special',
          type: TileType.special,
        );
        expect(specialTile.isSpecial, isTrue);
        expect(specialTile.isTax, isFalse);
      });
    });

    group('canBeOwned Property', () {
      test('should return true for book tiles', () {
        const bookTile = Tile(id: 1, name: 'Book', type: TileType.book);
        expect(bookTile.canBeOwned, isTrue);
      });

      test('should return true for publisher tiles', () {
        const publisherTile = Tile(
          id: 1,
          name: 'Publisher',
          type: TileType.publisher,
        );
        expect(publisherTile.canBeOwned, isTrue);
      });

      test('should return false for corner tiles', () {
        const cornerTile = Tile(id: 1, name: 'Corner', type: TileType.corner);
        expect(cornerTile.canBeOwned, isFalse);
      });

      test('should return false for chance tiles', () {
        const chanceTile = Tile(id: 1, name: 'Chance', type: TileType.chance);
        expect(chanceTile.canBeOwned, isFalse);
      });

      test('should return false for fate tiles', () {
        const fateTile = Tile(id: 1, name: 'Fate', type: TileType.fate);
        expect(fateTile.canBeOwned, isFalse);
      });

      test('should return false for tax tiles', () {
        const taxTile = Tile(id: 1, name: 'Tax', type: TileType.tax);
        expect(taxTile.canBeOwned, isFalse);
      });

      test('should return false for special tiles', () {
        const specialTile = Tile(
          id: 1,
          name: 'Special',
          type: TileType.special,
        );
        expect(specialTile.canBeOwned, isFalse);
      });
    });

    group('hasQuestion Property', () {
      test('should return true for book tiles', () {
        const bookTile = Tile(id: 1, name: 'Book', type: TileType.book);
        expect(bookTile.hasQuestion, isTrue);
      });

      test('should return true for publisher tiles', () {
        const publisherTile = Tile(
          id: 1,
          name: 'Publisher',
          type: TileType.publisher,
        );
        expect(publisherTile.hasQuestion, isTrue);
      });

      test('should return true for yazarlikOkulu special tiles', () {
        const specialTile = Tile(
          id: 1,
          name: 'Yazarlık Okulu',
          type: TileType.special,
          specialType: SpecialType.yazarlikOkulu,
        );
        expect(specialTile.hasQuestion, isTrue);
      });

      test('should return false for deEgitimVakfi special tiles', () {
        const specialTile = Tile(
          id: 1,
          name: 'DE Eğitim Vakfı',
          type: TileType.special,
          specialType: SpecialType.deEgitimVakfi,
        );
        expect(specialTile.hasQuestion, isFalse);
      });

      test('should return false for corner tiles', () {
        const cornerTile = Tile(id: 1, name: 'Corner', type: TileType.corner);
        expect(cornerTile.hasQuestion, isFalse);
      });

      test('should return false for chance tiles', () {
        const chanceTile = Tile(id: 1, name: 'Chance', type: TileType.chance);
        expect(chanceTile.hasQuestion, isFalse);
      });

      test('should return false for fate tiles', () {
        const fateTile = Tile(id: 1, name: 'Fate', type: TileType.fate);
        expect(fateTile.hasQuestion, isFalse);
      });

      test('should return false for tax tiles', () {
        const taxTile = Tile(id: 1, name: 'Tax', type: TileType.tax);
        expect(taxTile.hasQuestion, isFalse);
      });
    });

    group('causesTurnSkip Property', () {
      test('should return true for kutuphaneNobeti corner tiles', () {
        const tile = Tile(
          id: 1,
          name: 'Kütüphane Nöbeti',
          type: TileType.corner,
          cornerEffect: CornerEffect.kutuphaneNobeti,
        );
        expect(tile.causesTurnSkip, isTrue);
      });

      test('should return false for other corner effects', () {
        const tile = Tile(
          id: 1,
          name: 'Başlangıç',
          type: TileType.corner,
          cornerEffect: CornerEffect.baslangic,
        );
        expect(tile.causesTurnSkip, isFalse);
      });

      test('should return false for non-corner tiles', () {
        const bookTile = Tile(id: 1, name: 'Book', type: TileType.book);
        expect(bookTile.causesTurnSkip, isFalse);
      });
    });

    group('causesStarLoss Property', () {
      test('should return true for iflasRiski corner tiles', () {
        const tile = Tile(
          id: 1,
          name: 'İflas Riski',
          type: TileType.corner,
          cornerEffect: CornerEffect.iflasRiski,
        );
        expect(tile.causesStarLoss, isTrue);
      });

      test('should return true for tax tiles', () {
        const taxTile = Tile(id: 1, name: 'Tax', type: TileType.tax);
        expect(taxTile.causesStarLoss, isTrue);
      });

      test('should return false for other corner effects', () {
        const tile = Tile(
          id: 1,
          name: 'Başlangıç',
          type: TileType.corner,
          cornerEffect: CornerEffect.baslangic,
        );
        expect(tile.causesStarLoss, isFalse);
      });

      test('should return false for book tiles', () {
        const bookTile = Tile(id: 1, name: 'Book', type: TileType.book);
        expect(bookTile.causesStarLoss, isFalse);
      });
    });

    group('copyWith Method', () {
      test('should create a copy with updated id', () {
        final updatedTile = tile.copyWith(id: 2);
        expect(updatedTile.id, 2);
        expect(updatedTile.name, 'Test Tile');
      });

      test('should create a copy with updated name', () {
        final updatedTile = tile.copyWith(name: 'New Name');
        expect(updatedTile.name, 'New Name');
      });

      test('should create a copy with updated type', () {
        final updatedTile = tile.copyWith(type: TileType.publisher);
        expect(updatedTile.type, TileType.publisher);
      });

      test('should create a copy with updated owner', () {
        final updatedTile = tile.copyWith(owner: 'player1');
        expect(updatedTile.owner, 'player1');
      });

      test('should create a copy with updated cornerEffect', () {
        final updatedTile = tile.copyWith(
          type: TileType.corner,
          cornerEffect: CornerEffect.baslangic,
        );
        expect(updatedTile.cornerEffect, CornerEffect.baslangic);
      });

      test('should create a copy with updated group', () {
        final updatedTile = tile.copyWith(group: 3);
        expect(updatedTile.group, 3);
      });

      test('should create a copy with updated copyrightFee', () {
        final updatedTile = tile.copyWith(copyrightFee: 20);
        expect(updatedTile.copyrightFee, 20);
      });

      test('should create a copy with updated purchasePrice', () {
        final updatedTile = tile.copyWith(purchasePrice: 100);
        expect(updatedTile.purchasePrice, 100);
      });

      test('should create a copy with updated taxType', () {
        final updatedTile = tile.copyWith(
          type: TileType.tax,
          taxType: TaxType.yazarlikVergisi,
        );
        expect(updatedTile.taxType, TaxType.yazarlikVergisi);
      });

      test('should create a copy with updated taxRate', () {
        final updatedTile = tile.copyWith(type: TileType.tax, taxRate: 15);
        expect(updatedTile.taxRate, 15);
      });

      test('should create a copy with updated specialType', () {
        final updatedTile = tile.copyWith(
          type: TileType.special,
          specialType: SpecialType.deEgitimVakfi,
        );
        expect(updatedTile.specialType, SpecialType.deEgitimVakfi);
      });

      test('should create a copy with updated questionCategory', () {
        final updatedTile = tile.copyWith(
          questionCategory: QuestionCategory.edebiyatSanatlari,
        );
        expect(
          updatedTile.questionCategory,
          QuestionCategory.edebiyatSanatlari,
        );
      });

      test('should create a copy with multiple updates', () {
        final updatedTile = tile.copyWith(
          id: 5,
          name: 'Updated Tile',
          type: TileType.publisher,
          group: 2,
          copyrightFee: 25,
          purchasePrice: 150,
        );
        expect(updatedTile.id, 5);
        expect(updatedTile.name, 'Updated Tile');
        expect(updatedTile.type, TileType.publisher);
        expect(updatedTile.group, 2);
        expect(updatedTile.copyrightFee, 25);
        expect(updatedTile.purchasePrice, 150);
      });

      test('should not modify original tile when copying', () {
        final originalId = tile.id;
        final originalName = tile.name;

        tile.copyWith(id: 99, name: 'Changed');

        expect(tile.id, originalId);
        expect(tile.name, originalName);
      });
    });

    group('Edge Cases', () {
      test('should handle tile with id 0', () {
        const tile = Tile(id: 0, name: 'Zero ID Tile', type: TileType.book);
        expect(tile.id, 0);
      });

      test('should handle tile with very large id', () {
        const tile = Tile(id: 9999, name: 'Large ID Tile', type: TileType.book);
        expect(tile.id, 9999);
      });

      test('should handle tile with empty name', () {
        const tile = Tile(id: 1, name: '', type: TileType.book);
        expect(tile.name, '');
      });

      test('should handle tile with very long name', () {
        final longName = 'A' * 1000;
        final tile = Tile(id: 1, name: longName, type: TileType.book);
        expect(tile.name.length, 1000);
      });

      test('should handle tile with zero copyright fee', () {
        const tile = Tile(
          id: 1,
          name: 'Free Tile',
          type: TileType.book,
          copyrightFee: 0,
        );
        expect(tile.copyrightFee, 0);
      });

      test('should handle tile with very high copyright fee', () {
        const tile = Tile(
          id: 1,
          name: 'Expensive Tile',
          type: TileType.book,
          copyrightFee: 1000,
        );
        expect(tile.copyrightFee, 1000);
      });

      test('should handle tile with zero tax rate', () {
        const tile = Tile(
          id: 1,
          name: 'No Tax',
          type: TileType.tax,
          taxRate: 0,
        );
        expect(tile.taxRate, 0);
      });

      test('should handle tile with 100% tax rate', () {
        const tile = Tile(
          id: 1,
          name: 'Full Tax',
          type: TileType.tax,
          taxRate: 100,
        );
        expect(tile.taxRate, 100);
      });
    });

    group('Question Categories on Tiles', () {
      test('should support all question categories on book tiles', () {
        for (final category in QuestionCategory.values) {
          final tile = Tile(
            id: 1,
            name: 'Book Tile',
            type: TileType.book,
            questionCategory: category,
          );
          expect(tile.questionCategory, category);
        }
      });

      test('should support all question categories on publisher tiles', () {
        for (final category in QuestionCategory.values) {
          final tile = Tile(
            id: 1,
            name: 'Publisher Tile',
            type: TileType.publisher,
            questionCategory: category,
          );
          expect(tile.questionCategory, category);
        }
      });

      test('should support question categories on yazarlikOkulu tiles', () {
        final tile = Tile(
          id: 1,
          name: 'Yazarlık Okulu',
          type: TileType.special,
          specialType: SpecialType.yazarlikOkulu,
          questionCategory: QuestionCategory.edebiyatAkimlari,
        );
        expect(tile.questionCategory, QuestionCategory.edebiyatAkimlari);
      });
    });
  });
}

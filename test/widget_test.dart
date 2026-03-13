import 'package:flutter_test/flutter_test.dart';
import 'package:suerte_ya/models/lottery_game.dart';
import 'package:suerte_ya/services/prize_checker_service.dart';
import 'package:suerte_ya/models/draw_result.dart';

void main() {
  group('LotteryGame', () {
    test('getById returns correct game', () {
      final game = LotteryGame.getById(14);
      expect(game, isNotNull);
      expect(game!.name, 'Euromillones');
    });

    test('getByCategory returns games', () {
      final selae = LotteryGame.getByCategory(GameCategory.selae);
      expect(selae.isNotEmpty, true);
    });
  });

  group('PrizeCheckerService', () {
    final checker = PrizeCheckerService();

    test('Euromillones 5+2 wins first prize', () {
      final result = DrawResult(
        gameId: 14,
        gameName: 'Euromillones',
        date: DateTime.now(),
        mainNumbers: [
          const ResultNumber(value: '5'),
          const ResultNumber(value: '12'),
          const ResultNumber(value: '23'),
          const ResultNumber(value: '34'),
          const ResultNumber(value: '45'),
        ],
        extraNumbers: [
          const ResultNumber(value: '3', label: 'Estrella'),
          const ResultNumber(value: '7', label: 'Estrella'),
        ],
        prizes: [],
      );

      final matches = checker.checkNumbers(
        gameId: 14,
        userMainNumbers: [5, 12, 23, 34, 45],
        userExtraNumbers: [3, 7],
        result: result,
      );

      expect(matches.length, 1);
      expect(matches.first.category, '1a');
    });

    test('Primitiva 3 aciertos wins 5th prize', () {
      final result = DrawResult(
        gameId: 1,
        gameName: 'La Primitiva',
        date: DateTime.now(),
        mainNumbers: [
          const ResultNumber(value: '5'),
          const ResultNumber(value: '12'),
          const ResultNumber(value: '23'),
          const ResultNumber(value: '34'),
          const ResultNumber(value: '41'),
          const ResultNumber(value: '49'),
        ],
        extraNumbers: [
          const ResultNumber(value: '3', label: 'Complementario'),
          const ResultNumber(value: '7', label: 'Reintegro'),
        ],
        prizes: [],
      );

      final matches = checker.checkNumbers(
        gameId: 1,
        userMainNumbers: [5, 12, 23, 1, 2, 3],
        userExtraNumbers: [9],
        result: result,
      );

      expect(matches.length, 1);
      expect(matches.first.category, '5a');
    });
  });
}

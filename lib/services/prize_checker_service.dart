import '../models/draw_result.dart';
import '../models/lottery_game.dart';

class PrizeMatch {
  final String category;
  final String description;
  final double? estimatedPrize;

  const PrizeMatch({
    required this.category,
    required this.description,
    this.estimatedPrize,
  });
}

class PrizeCheckerService {
  /// Checks user numbers against a draw result
  List<PrizeMatch> checkNumbers({
    required int gameId,
    required List<int> userMainNumbers,
    required List<int> userExtraNumbers,
    required DrawResult result,
  }) {
    final game = LotteryGame.getById(gameId);
    if (game == null) return [];

    switch (gameId) {
      case 1: // Primitiva
        return _checkPrimitiva(userMainNumbers, userExtraNumbers, result);
      case 2: // Bonoloto
        return _checkBonoloto(userMainNumbers, userExtraNumbers, result);
      case 3: // El Gordo
        return _checkGordo(userMainNumbers, userExtraNumbers, result);
      case 14: // Euromillones
        return _checkEuromillones(userMainNumbers, userExtraNumbers, result);
      case 38: // Eurodreams
        return _checkEurodreams(userMainNumbers, userExtraNumbers, result);
      default:
        return _checkGeneric(userMainNumbers, userExtraNumbers, result);
    }
  }

  // --- Primitiva (6/49 + Reintegro) ---
  List<PrizeMatch> _checkPrimitiva(
    List<int> userNums,
    List<int> userExtra,
    DrawResult result,
  ) {
    final drawnNums = result.mainNumbers.map((n) => int.tryParse(n.value) ?? 0).toList();
    final complementario = result.extraNumbers
        .where((n) => n.label == 'Complementario')
        .map((n) => int.tryParse(n.value) ?? 0)
        .firstOrNull;
    final reintegro = result.extraNumbers
        .where((n) => n.label == 'Reintegro')
        .map((n) => int.tryParse(n.value) ?? 0)
        .firstOrNull;

    final mainMatches = userNums.where((n) => drawnNums.contains(n)).length;
    final hasComplementario = complementario != null && userNums.contains(complementario);
    final hasReintegro = reintegro != null && userExtra.contains(reintegro);

    final prizes = <PrizeMatch>[];

    if (mainMatches == 6 && hasReintegro) {
      prizes.add(const PrizeMatch(
        category: 'Especial',
        description: '6 aciertos + Reintegro',
      ));
    } else if (mainMatches == 6) {
      prizes.add(const PrizeMatch(
        category: '1a',
        description: '6 aciertos',
      ));
    } else if (mainMatches == 5 && hasComplementario) {
      prizes.add(const PrizeMatch(
        category: '2a',
        description: '5 aciertos + Complementario',
      ));
    } else if (mainMatches == 5) {
      prizes.add(const PrizeMatch(
        category: '3a',
        description: '5 aciertos',
      ));
    } else if (mainMatches == 4) {
      prizes.add(const PrizeMatch(
        category: '4a',
        description: '4 aciertos',
      ));
    } else if (mainMatches == 3) {
      prizes.add(const PrizeMatch(
        category: '5a',
        description: '3 aciertos',
      ));
    }

    if (hasReintegro && mainMatches < 6) {
      prizes.add(const PrizeMatch(
        category: 'Reintegro',
        description: 'Reintegro',
      ));
    }

    return prizes;
  }

  // --- Bonoloto (6/49 + Reintegro) ---
  List<PrizeMatch> _checkBonoloto(
    List<int> userNums,
    List<int> userExtra,
    DrawResult result,
  ) {
    // Same structure as Primitiva
    return _checkPrimitiva(userNums, userExtra, result);
  }

  // --- El Gordo (5/54 + Número Clave 0-9) ---
  List<PrizeMatch> _checkGordo(
    List<int> userNums,
    List<int> userExtra,
    DrawResult result,
  ) {
    final drawnNums = result.mainNumbers.map((n) => int.tryParse(n.value) ?? 0).toList();
    final clave = result.extraNumbers.isNotEmpty
        ? int.tryParse(result.extraNumbers.first.value) ?? -1
        : -1;

    final mainMatches = userNums.where((n) => drawnNums.contains(n)).length;
    final hasClave = userExtra.isNotEmpty && userExtra.first == clave;

    final prizes = <PrizeMatch>[];

    if (mainMatches == 5 && hasClave) {
      prizes.add(const PrizeMatch(category: '1a', description: '5+1 aciertos'));
    } else if (mainMatches == 5) {
      prizes.add(const PrizeMatch(category: '2a', description: '5 aciertos'));
    } else if (mainMatches == 4 && hasClave) {
      prizes.add(const PrizeMatch(category: '3a', description: '4+1 aciertos'));
    } else if (mainMatches == 4) {
      prizes.add(const PrizeMatch(category: '4a', description: '4 aciertos'));
    } else if (mainMatches == 3 && hasClave) {
      prizes.add(const PrizeMatch(category: '5a', description: '3+1 aciertos'));
    } else if (mainMatches == 3) {
      prizes.add(const PrizeMatch(category: '6a', description: '3 aciertos'));
    } else if (mainMatches == 2 && hasClave) {
      prizes.add(const PrizeMatch(category: '7a', description: '2+1 aciertos'));
    } else if (mainMatches == 2) {
      prizes.add(const PrizeMatch(category: '8a', description: '2 aciertos'));
    }

    return prizes;
  }

  // --- Euromillones (5/50 + 2 Estrellas /12) ---
  List<PrizeMatch> _checkEuromillones(
    List<int> userNums,
    List<int> userExtra,
    DrawResult result,
  ) {
    final drawnNums = result.mainNumbers.map((n) => int.tryParse(n.value) ?? 0).toList();
    final drawnStars = result.extraNumbers.map((n) => int.tryParse(n.value) ?? 0).toList();

    final mainMatches = userNums.where((n) => drawnNums.contains(n)).length;
    final starMatches = userExtra.where((n) => drawnStars.contains(n)).length;

    final key = '$mainMatches+$starMatches';

    const prizeTable = {
      '5+2': PrizeMatch(category: '1a', description: '5 + 2 estrellas'),
      '5+1': PrizeMatch(category: '2a', description: '5 + 1 estrella'),
      '5+0': PrizeMatch(category: '3a', description: '5 aciertos'),
      '4+2': PrizeMatch(category: '4a', description: '4 + 2 estrellas'),
      '4+1': PrizeMatch(category: '5a', description: '4 + 1 estrella'),
      '3+2': PrizeMatch(category: '6a', description: '3 + 2 estrellas'),
      '4+0': PrizeMatch(category: '7a', description: '4 aciertos'),
      '2+2': PrizeMatch(category: '8a', description: '2 + 2 estrellas'),
      '3+1': PrizeMatch(category: '9a', description: '3 + 1 estrella'),
      '3+0': PrizeMatch(category: '10a', description: '3 aciertos'),
      '1+2': PrizeMatch(category: '11a', description: '1 + 2 estrellas'),
      '2+1': PrizeMatch(category: '12a', description: '2 + 1 estrella'),
      '2+0': PrizeMatch(category: '13a', description: '2 aciertos'),
    };

    if (prizeTable.containsKey(key)) {
      return [prizeTable[key]!];
    }
    return [];
  }

  // --- Eurodreams (6/40 + 1 Sueño /5) ---
  List<PrizeMatch> _checkEurodreams(
    List<int> userNums,
    List<int> userExtra,
    DrawResult result,
  ) {
    final drawnNums = result.mainNumbers.map((n) => int.tryParse(n.value) ?? 0).toList();
    final drawnDream = result.extraNumbers.isNotEmpty
        ? int.tryParse(result.extraNumbers.first.value) ?? -1
        : -1;

    final mainMatches = userNums.where((n) => drawnNums.contains(n)).length;
    final hasDream = userExtra.isNotEmpty && userExtra.first == drawnDream;

    final prizes = <PrizeMatch>[];

    if (mainMatches == 6 && hasDream) {
      prizes.add(const PrizeMatch(category: '1a', description: '6+1 - 20.000€/mes durante 30 años'));
    } else if (mainMatches == 6) {
      prizes.add(const PrizeMatch(category: '2a', description: '6 - 2.000€/mes durante 5 años'));
    } else if (mainMatches == 5 && hasDream) {
      prizes.add(const PrizeMatch(category: '3a', description: '5+1 aciertos'));
    } else if (mainMatches == 5) {
      prizes.add(const PrizeMatch(category: '4a', description: '5 aciertos'));
    } else if (mainMatches == 4) {
      prizes.add(const PrizeMatch(category: '5a', description: '4 aciertos'));
    } else if (mainMatches == 3) {
      prizes.add(const PrizeMatch(category: '6a', description: '3 aciertos'));
    } else if (mainMatches == 2) {
      prizes.add(const PrizeMatch(category: '7a', description: '2 aciertos'));
    }

    return prizes;
  }

  // --- Generic checker ---
  List<PrizeMatch> _checkGeneric(
    List<int> userNums,
    List<int> userExtra,
    DrawResult result,
  ) {
    final drawnNums = result.mainNumbers.map((n) => int.tryParse(n.value) ?? 0).toList();
    final mainMatches = userNums.where((n) => drawnNums.contains(n)).length;

    if (mainMatches > 0) {
      return [
        PrizeMatch(
          category: 'Coincidencias',
          description: '$mainMatches número(s) acertado(s)',
        ),
      ];
    }
    return [];
  }
}

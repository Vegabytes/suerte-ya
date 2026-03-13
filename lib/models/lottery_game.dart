enum GameCategory { selae, once, catalunya, extraordinarios }

class LotteryGame {
  final int id;
  final String name;
  final String shortName;
  final String icon;
  final GameCategory category;
  final List<String> drawDays;
  final String? description;
  final int mainNumbers;
  final int mainNumbersMax;
  final int? extraNumbers;
  final int? extraNumbersMax;
  final String? extraNumbersLabel;

  const LotteryGame({
    required this.id,
    required this.name,
    required this.shortName,
    required this.icon,
    required this.category,
    required this.drawDays,
    this.description,
    required this.mainNumbers,
    required this.mainNumbersMax,
    this.extraNumbers,
    this.extraNumbersMax,
    this.extraNumbersLabel,
  });

  static const List<LotteryGame> allGames = [
    // SELAE
    LotteryGame(
      id: 1,
      name: 'La Primitiva',
      shortName: 'Primitiva',
      icon: '🎱',
      category: GameCategory.selae,
      drawDays: ['jueves', 'sábado'],
      mainNumbers: 6,
      mainNumbersMax: 49,
      extraNumbers: 1,
      extraNumbersMax: 9,
      extraNumbersLabel: 'Reintegro',
    ),
    LotteryGame(
      id: 2,
      name: 'Bonoloto',
      shortName: 'Bonoloto',
      icon: '💰',
      category: GameCategory.selae,
      drawDays: ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado'],
      mainNumbers: 6,
      mainNumbersMax: 49,
      extraNumbers: 1,
      extraNumbersMax: 9,
      extraNumbersLabel: 'Reintegro',
    ),
    LotteryGame(
      id: 3,
      name: 'El Gordo de la Primitiva',
      shortName: 'El Gordo',
      icon: '🐷',
      category: GameCategory.selae,
      drawDays: ['domingo'],
      mainNumbers: 5,
      mainNumbersMax: 54,
      extraNumbers: 1,
      extraNumbersMax: 9,
      extraNumbersLabel: 'Número clave',
    ),
    LotteryGame(
      id: 9,
      name: 'Lotería Nacional',
      shortName: 'Nacional',
      icon: '🏛️',
      category: GameCategory.selae,
      drawDays: ['jueves', 'sábado'],
      mainNumbers: 5,
      mainNumbersMax: 99999,
    ),
    LotteryGame(
      id: 14,
      name: 'Euromillones',
      shortName: 'Euromillones',
      icon: '⭐',
      category: GameCategory.selae,
      drawDays: ['martes', 'viernes'],
      mainNumbers: 5,
      mainNumbersMax: 50,
      extraNumbers: 2,
      extraNumbersMax: 12,
      extraNumbersLabel: 'Estrellas',
    ),
    LotteryGame(
      id: 38,
      name: 'Eurodreams',
      shortName: 'Eurodreams',
      icon: '🌙',
      category: GameCategory.selae,
      drawDays: ['lunes', 'jueves'],
      mainNumbers: 6,
      mainNumbersMax: 40,
      extraNumbers: 1,
      extraNumbersMax: 5,
      extraNumbersLabel: 'Sueño',
    ),
    LotteryGame(
      id: 13,
      name: 'La Quiniela',
      shortName: 'Quiniela',
      icon: '⚽',
      category: GameCategory.selae,
      drawDays: ['domingo'],
      mainNumbers: 15,
      mainNumbersMax: 2,
    ),
    LotteryGame(
      id: 16,
      name: 'Lototurf',
      shortName: 'Lototurf',
      icon: '🐴',
      category: GameCategory.selae,
      drawDays: ['domingo'],
      mainNumbers: 6,
      mainNumbersMax: 31,
      extraNumbers: 1,
      extraNumbersMax: 12,
      extraNumbersLabel: 'Caballo',
    ),
    LotteryGame(
      id: 18,
      name: 'El Quinigol',
      shortName: 'Quinigol',
      icon: '🥅',
      category: GameCategory.selae,
      drawDays: ['miércoles', 'domingo'],
      mainNumbers: 6,
      mainNumbersMax: 9,
    ),

    // ONCE
    LotteryGame(
      id: 10,
      name: 'Cupón ONCE',
      shortName: 'ONCE',
      icon: '🎟️',
      category: GameCategory.once,
      drawDays: ['lunes', 'martes', 'miércoles', 'jueves', 'viernes'],
      mainNumbers: 5,
      mainNumbersMax: 99999,
      extraNumbers: 1,
      extraNumbersMax: 9,
      extraNumbersLabel: 'Serie',
    ),
    LotteryGame(
      id: 11,
      name: 'Cuponazo',
      shortName: 'Cuponazo',
      icon: '🎉',
      category: GameCategory.once,
      drawDays: ['viernes'],
      mainNumbers: 5,
      mainNumbersMax: 99999,
      extraNumbers: 1,
      extraNumbersMax: 9,
      extraNumbersLabel: 'Serie',
    ),
    LotteryGame(
      id: 12,
      name: 'Cupón Fin de Semana',
      shortName: 'Fin Semana',
      icon: '🌅',
      category: GameCategory.once,
      drawDays: ['sábado', 'domingo'],
      mainNumbers: 5,
      mainNumbersMax: 99999,
      extraNumbers: 1,
      extraNumbersMax: 9,
      extraNumbersLabel: 'Serie',
    ),
    LotteryGame(
      id: 22,
      name: 'Super ONCE',
      shortName: 'Super ONCE',
      icon: '🦸',
      category: GameCategory.once,
      drawDays: ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'],
      mainNumbers: 5,
      mainNumbersMax: 99,
    ),
    LotteryGame(
      id: 27,
      name: 'Eurojackpot',
      shortName: 'Eurojackpot',
      icon: '🇪🇺',
      category: GameCategory.once,
      drawDays: ['martes', 'viernes'],
      mainNumbers: 5,
      mainNumbersMax: 50,
      extraNumbers: 2,
      extraNumbersMax: 12,
      extraNumbersLabel: 'Soles',
    ),

    LotteryGame(
      id: 19,
      name: 'ONCE 7/39',
      shortName: '7/39',
      icon: '7️⃣',
      category: GameCategory.once,
      drawDays: ['viernes'],
      mainNumbers: 7,
      mainNumbersMax: 39,
    ),
    LotteryGame(
      id: 35,
      name: 'Triplex',
      shortName: 'Triplex',
      icon: '3️⃣',
      category: GameCategory.once,
      drawDays: ['lunes', 'martes', 'miércoles', 'jueves', 'viernes'],
      mainNumbers: 3,
      mainNumbersMax: 9,
    ),
    LotteryGame(
      id: 36,
      name: 'ONCE Mi Día',
      shortName: 'Mi Día',
      icon: '📅',
      category: GameCategory.once,
      drawDays: ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'],
      mainNumbers: 5,
      mainNumbersMax: 99999,
      extraNumbers: 1,
      extraNumbersMax: 9,
      extraNumbersLabel: 'Serie',
    ),

    // Catalunya
    LotteryGame(
      id: 4,
      name: '6/49 Catalunya',
      shortName: '6/49',
      icon: '🔴',
      category: GameCategory.catalunya,
      drawDays: ['miércoles', 'sábado'],
      mainNumbers: 6,
      mainNumbersMax: 49,
    ),
    LotteryGame(
      id: 20,
      name: 'Trío',
      shortName: 'Trío',
      icon: '🎯',
      category: GameCategory.catalunya,
      drawDays: ['martes', 'jueves', 'sábado'],
      mainNumbers: 3,
      mainNumbersMax: 9,
    ),
    LotteryGame(
      id: 21,
      name: 'Super 10',
      shortName: 'Super 10',
      icon: '🔟',
      category: GameCategory.catalunya,
      drawDays: ['lunes', 'miércoles', 'viernes'],
      mainNumbers: 10,
      mainNumbersMax: 25,
    ),
    LotteryGame(
      id: 37,
      name: 'La Grossa',
      shortName: 'La Grossa',
      icon: '🏆',
      category: GameCategory.catalunya,
      drawDays: ['lunes'],
      mainNumbers: 5,
      mainNumbersMax: 54,
      extraNumbers: 1,
      extraNumbersMax: 9,
      extraNumbersLabel: 'Número clave',
    ),

    // Extraordinarios
    LotteryGame(
      id: 23,
      name: 'Cupón Extraordinario',
      shortName: 'Extra ONCE',
      icon: '🎊',
      category: GameCategory.extraordinarios,
      drawDays: ['variable'],
      mainNumbers: 5,
      mainNumbersMax: 99999,
      extraNumbers: 1,
      extraNumbersMax: 9,
      extraNumbersLabel: 'Serie',
    ),
    LotteryGame(
      id: 26,
      name: 'Sorteo de Navidad',
      shortName: 'Navidad',
      icon: '🎄',
      category: GameCategory.extraordinarios,
      drawDays: ['22 diciembre'],
      mainNumbers: 5,
      mainNumbersMax: 99999,
    ),
    LotteryGame(
      id: 25,
      name: 'El Niño',
      shortName: 'El Niño',
      icon: '👶',
      category: GameCategory.extraordinarios,
      drawDays: ['6 enero'],
      mainNumbers: 5,
      mainNumbersMax: 99999,
    ),
  ];

  static LotteryGame? getById(int id) {
    try {
      return allGames.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<LotteryGame> getByCategory(GameCategory category) {
    return allGames.where((g) => g.category == category).toList();
  }
}

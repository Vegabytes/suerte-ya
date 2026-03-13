class DrawResult {
  final int gameId;
  final String gameName;
  final DateTime date;
  final int? drawNumber;
  final List<ResultNumber> mainNumbers;
  final List<ResultNumber> extraNumbers;
  final List<Prize> prizes;
  final String? joker;

  const DrawResult({
    required this.gameId,
    required this.gameName,
    required this.date,
    this.drawNumber,
    required this.mainNumbers,
    required this.extraNumbers,
    required this.prizes,
    this.joker,
  });

  factory DrawResult.fromJson(Map<String, dynamic> json) {
    return DrawResult(
      gameId: json['gameId'] as int,
      gameName: json['gameName'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      drawNumber: json['drawNumber'] as int?,
      mainNumbers: (json['mainNumbers'] as List<dynamic>?)
              ?.map((n) => ResultNumber.fromJson(n as Map<String, dynamic>))
              .toList() ??
          [],
      extraNumbers: (json['extraNumbers'] as List<dynamic>?)
              ?.map((n) => ResultNumber.fromJson(n as Map<String, dynamic>))
              .toList() ??
          [],
      prizes: (json['prizes'] as List<dynamic>?)
              ?.map((p) => Prize.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      joker: json['joker'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'gameId': gameId,
        'gameName': gameName,
        'date': date.toIso8601String(),
        'drawNumber': drawNumber,
        'mainNumbers': mainNumbers.map((n) => n.toJson()).toList(),
        'extraNumbers': extraNumbers.map((n) => n.toJson()).toList(),
        'prizes': prizes.map((p) => p.toJson()).toList(),
        'joker': joker,
      };
}

class ResultNumber {
  final String value;
  final String? label;

  const ResultNumber({required this.value, this.label});

  factory ResultNumber.fromJson(Map<String, dynamic> json) {
    return ResultNumber(
      value: json['value'].toString(),
      label: json['label'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'value': value, 'label': label};
}

class Prize {
  final String category;
  final String description;
  final int? winners;
  final double? amount;

  const Prize({
    required this.category,
    required this.description,
    this.winners,
    this.amount,
  });

  factory Prize.fromJson(Map<String, dynamic> json) {
    return Prize(
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      winners: json['winners'] as int?,
      amount: (json['amount'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'description': description,
        'winners': winners,
        'amount': amount,
      };
}

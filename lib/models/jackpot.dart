class Jackpot {
  final int gameId;
  final String gameName;
  final double amount;
  final DateTime nextDraw;

  const Jackpot({
    required this.gameId,
    required this.gameName,
    required this.amount,
    required this.nextDraw,
  });

  factory Jackpot.fromJson(Map<String, dynamic> json) {
    return Jackpot(
      gameId: json['gameId'] as int,
      gameName: json['gameName'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      nextDraw: DateTime.parse(json['nextDraw'] as String),
    );
  }

  String get formattedAmount {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(0)}M€';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}.000€';
    }
    return '${amount.toStringAsFixed(0)}€';
  }
}

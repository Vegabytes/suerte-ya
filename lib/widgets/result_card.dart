import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/draw_result.dart';
import '../models/lottery_game.dart';
import 'number_ball.dart';

class ResultCard extends StatelessWidget {
  final DrawResult result;
  final LotteryGame? game;
  final VoidCallback? onTap;

  const ResultCard({
    super.key,
    required this.result,
    this.game,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(game?.icon ?? '🎱', style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game?.name ?? result.gameName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _formatShortDate(result.date),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),

              // Numbers
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.start,
                children: [
                  ...result.mainNumbers.map((n) => NumberBall(
                        number: n.value,
                        color: AppTheme.primary,
                        size: 36,
                      )),
                  ...result.extraNumbers.map((n) => NumberBall(
                        number: n.value,
                        color: AppTheme.secondary,
                        textColor: AppTheme.primaryDark,
                        size: 36,
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatShortDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

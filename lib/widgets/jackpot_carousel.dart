import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/jackpot.dart';
import '../models/lottery_game.dart';

class JackpotCarousel extends StatelessWidget {
  final List<Jackpot> jackpots;

  const JackpotCarousel({super.key, required this.jackpots});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.85),
        itemCount: jackpots.length,
        itemBuilder: (context, index) {
          final jackpot = jackpots[index];
          final game = LotteryGame.getById(jackpot.gameId);
          return _JackpotCard(jackpot: jackpot, game: game);
        },
      ),
    );
  }
}

class _JackpotCard extends StatelessWidget {
  final Jackpot jackpot;
  final LotteryGame? game;

  const _JackpotCard({required this.jackpot, this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary,
            AppTheme.primaryLight,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(game?.icon ?? '💰', style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  jackpot.gameName.isNotEmpty
                      ? jackpot.gameName
                      : (game?.name ?? 'Bote'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Text(
              jackpot.formattedAmount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            Text(
              'Próximo sorteo: ${_formatDate(jackpot.nextDraw)}',
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return '${days[date.weekday - 1]} ${date.day}/${date.month}';
  }
}

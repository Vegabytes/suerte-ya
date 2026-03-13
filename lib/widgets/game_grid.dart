import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/lottery_game.dart';
import '../services/storage_service.dart';

class GameGrid extends StatelessWidget {
  final Function(int) onGameTap;
  final StorageService storageService;

  const GameGrid({
    super.key,
    required this.onGameTap,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCategorySection('Loterías del Estado', GameCategory.selae, AppTheme.selaeColor),
        _buildCategorySection('ONCE', GameCategory.once, AppTheme.onceColor),
        _buildCategorySection('Lotería de Catalunya', GameCategory.catalunya, AppTheme.catalunyaColor),
        _buildCategorySection('Extraordinarios', GameCategory.extraordinarios, AppTheme.extraordinariosColor),
      ],
    );
  }

  Widget _buildCategorySection(String title, GameCategory category, Color color) {
    final games = LotteryGame.getByCategory(category);
    if (games.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.1,
            ),
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              final isFav = storageService.isFavorite(game.id);
              return _GameTile(
                game: game,
                color: color,
                isFavorite: isFav,
                onTap: () => onGameTap(game.id),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GameTile extends StatelessWidget {
  final LotteryGame game;
  final Color color;
  final bool isFavorite;
  final VoidCallback onTap;

  const _GameTile({
    required this.game,
    required this.color,
    required this.isFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Text(game.icon, style: const TextStyle(fontSize: 28)),
                  if (isFavorite)
                    const Positioned(
                      right: -4,
                      top: -4,
                      child: Icon(Icons.star, size: 14, color: AppTheme.secondary),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  game.shortName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

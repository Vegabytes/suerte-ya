import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/lottery_game.dart';
import '../services/storage_service.dart';
import 'game_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final StorageService storageService;

  const FavoritesScreen({super.key, required this.storageService});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    final favoriteIds = widget.storageService.getFavorites();
    final favoriteGames = favoriteIds
        .map((id) => LotteryGame.getById(id))
        .whereType<LotteryGame>()
        .toList();

    if (favoriteGames.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tienes favoritos',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Añade juegos desde los resultados',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favoriteGames.length,
      itemBuilder: (context, index) {
        final game = favoriteGames[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Text(game.icon, style: const TextStyle(fontSize: 32)),
            title: Text(
              game.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Sorteos: ${game.drawDays.join(', ')}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.star, color: AppTheme.secondary),
              onPressed: () async {
                await widget.storageService.toggleFavorite(game.id);
                setState(() {});
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GameDetailScreen(
                    gameId: game.id,
                    storageService: widget.storageService,
                  ),
                ),
              ).then((_) => setState(() {}));
            },
          ),
        );
      },
    );
  }
}

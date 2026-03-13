import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/lottery_game.dart';
import '../models/draw_result.dart';
import '../services/lottery_service.dart';
import '../services/storage_service.dart';
import '../widgets/number_ball.dart';
import '../widgets/prize_table.dart';

class GameDetailScreen extends StatefulWidget {
  final int gameId;
  final StorageService storageService;

  const GameDetailScreen({
    super.key,
    required this.gameId,
    required this.storageService,
  });

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  final LotteryService _lotteryService = LotteryService();
  LotteryGame? _game;
  DrawResult? _result;
  bool _loading = true;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _game = LotteryGame.getById(widget.gameId);
    _isFavorite = widget.storageService.isFavorite(widget.gameId);
    _loadResult();
  }

  Future<void> _loadResult() async {
    setState(() => _loading = true);
    try {
      final result = await _lotteryService.getLatestResult(widget.gameId);
      if (mounted) {
        setState(() {
          _result = result;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toggleFavorite() async {
    await widget.storageService.toggleFavorite(widget.gameId);
    setState(() => _isFavorite = !_isFavorite);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite ? 'Añadido a favoritos' : 'Eliminado de favoritos'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;

    return Scaffold(
      appBar: AppBar(
        title: Text(game?.name ?? 'Juego'),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.star : Icons.star_border),
            color: _isFavorite ? AppTheme.secondary : Colors.white,
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadResult,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _result == null
                ? _buildNoResults()
                : _buildResults(),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_game?.icon ?? '🎱', style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'No hay resultados disponibles',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadResult,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final result = _result!;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Draw info header
          _buildDrawHeader(result),
          const SizedBox(height: 24),

          // Numbers
          _buildNumbersSection(result),
          const SizedBox(height: 24),

          // Prize table
          if (result.prizes.isNotEmpty) ...[
            const Text(
              'Premios',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            PrizeTable(prizes: result.prizes),
          ],
        ],
      ),
    );
  }

  Widget _buildDrawHeader(DrawResult result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(_game?.icon ?? '🎱', style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _game?.name ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(result.date),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (result.drawNumber != null)
                    Text(
                      'Sorteo nº ${result.drawNumber}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumbersSection(DrawResult result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Combinación Ganadora',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 16),

            // Main numbers
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: result.mainNumbers
                  .map((n) => NumberBall(
                        number: n.value,
                        color: AppTheme.primary,
                        size: 48,
                      ))
                  .toList(),
            ),

            // Extra numbers
            if (result.extraNumbers.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: result.extraNumbers.map((n) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      NumberBall(
                        number: n.value,
                        color: AppTheme.secondary,
                        textColor: AppTheme.primaryDark,
                        size: 44,
                      ),
                      if (n.label != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            n.label!,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ],

            // Joker
            if (result.joker != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Joker: ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    result.joker!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const days = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
    const months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${days[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}

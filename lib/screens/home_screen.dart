import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/lottery_game.dart';
import '../models/draw_result.dart';
import '../models/jackpot.dart';
import '../services/lottery_service.dart';
import '../services/storage_service.dart';
import '../widgets/jackpot_carousel.dart';
import '../widgets/result_card.dart';
import '../widgets/game_grid.dart';
import 'game_detail_screen.dart';


class HomeScreen extends StatefulWidget {
  final StorageService storageService;

  const HomeScreen({super.key, required this.storageService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LotteryService _lotteryService = LotteryService();
  List<DrawResult> _latestResults = [];
  List<Jackpot> _jackpots = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    // Load cached results first
    _latestResults = widget.storageService.getCachedResults();
    if (_latestResults.isNotEmpty) {
      setState(() => _loading = false);
    }

    // Fetch fresh data
    try {
      final results = await _lotteryService.getAllLatestResults();
      final jackpots = await _lotteryService.getSelaeJackpots();

      if (mounted) {
        setState(() {
          if (results.isNotEmpty) _latestResults = results;
          _jackpots = jackpots;
          _loading = false;
        });

        // Cache results
        for (final r in results) {
          await widget.storageService.cacheResult(r);
        }
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          // Jackpots carousel
          if (_jackpots.isNotEmpty)
            SliverToBoxAdapter(
              child: JackpotCarousel(jackpots: _jackpots),
            ),

          // Section: Latest Results
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'Últimos Resultados',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),

          if (_loading && _latestResults.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_latestResults.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No se pudieron cargar los resultados',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Desliza hacia abajo para reintentar',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final result = _latestResults[index];
                  final game = LotteryGame.getById(result.gameId);
                  return ResultCard(
                    result: result,
                    game: game,
                    onTap: () => _openGameDetail(result.gameId),
                  );
                },
                childCount: _latestResults.length,
              ),
            ),

          // Section: All Games
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Todos los Juegos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: GameGrid(
              onGameTap: _openGameDetail,
              storageService: widget.storageService,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  void _openGameDetail(int gameId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameDetailScreen(
          gameId: gameId,
          storageService: widget.storageService,
        ),
      ),
    );
  }
}

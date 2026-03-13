import 'dart:math';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/lottery_game.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  LotteryGame? _selectedGame;

  // Simulated frequency data (in production, fetched from API/scraped)
  Map<int, int> _frequencies = {};
  bool _loading = false;

  void _loadStats() {
    if (_selectedGame == null) return;
    setState(() => _loading = true);

    // Simulate loading stats
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final random = Random(42); // Deterministic seed for demo
      final max = _selectedGame!.mainNumbersMax;
      final freqs = <int, int>{};

      if (max <= 54) {
        for (int i = 1; i <= max; i++) {
          freqs[i] = random.nextInt(80) + 20; // Frequency between 20-100
        }
      }

      setState(() {
        _frequencies = freqs;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.bar_chart, color: AppTheme.primary),
                        SizedBox(width: 8),
                        Text(
                          'Frecuencia de Números',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<LotteryGame>(
                      initialValue: _selectedGame,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      hint: const Text('Elige un juego'),
                      items: LotteryGame.allGames
                          .where((g) =>
                              g.mainNumbersMax <= 54 &&
                              g.category != GameCategory.extraordinarios)
                          .map((game) => DropdownMenuItem(
                                value: game,
                                child: Text('${game.icon} ${game.name}'),
                              ))
                          .toList(),
                      onChanged: (game) {
                        setState(() {
                          _selectedGame = game;
                          _frequencies = {};
                        });
                        _loadStats();
                      },
                    ),
                  ],
                ),
              ),
            ),

            if (_loading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              ),

            if (_frequencies.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildHotCold(),
              const SizedBox(height: 16),
              _buildFrequencyBars(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHotCold() {
    final sorted = _frequencies.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final hot = sorted.take(6).toList();
    final cold = sorted.reversed.take(6).toList();

    return Row(
      children: [
        Expanded(
          child: Card(
            color: Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_fire_department,
                          color: Colors.red, size: 20),
                      SizedBox(width: 4),
                      Text('Calientes',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: hot
                        .map((e) => _MiniNumberBall(
                              number: e.key,
                              color: Colors.red,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.ac_unit, color: Colors.blue, size: 20),
                      SizedBox(width: 4),
                      Text('Fríos',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: cold
                        .map((e) => _MiniNumberBall(
                              number: e.key,
                              color: Colors.blue,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencyBars() {
    final maxFreq = _frequencies.values.reduce(max);
    final sortedEntries = _frequencies.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Todas las frecuencias',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...sortedEntries.map((entry) {
              final ratio = entry.value / maxFreq;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 30,
                      child: Text(
                        entry.key.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 18,
                          backgroundColor: Colors.grey[100],
                          valueColor: AlwaysStoppedAnimation(
                            Color.lerp(Colors.blue, Colors.red, ratio)!,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 30,
                      child: Text(
                        entry.value.toString(),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _MiniNumberBall extends StatelessWidget {
  final int number;
  final Color color;

  const _MiniNumberBall({required this.number, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: Center(
        child: Text(
          number.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

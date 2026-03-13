import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../models/lottery_game.dart';
import '../widgets/number_ball.dart';

class RandomGeneratorScreen extends StatefulWidget {
  const RandomGeneratorScreen({super.key});

  @override
  State<RandomGeneratorScreen> createState() => _RandomGeneratorScreenState();
}

class _RandomGeneratorScreenState extends State<RandomGeneratorScreen>
    with SingleTickerProviderStateMixin {
  LotteryGame? _selectedGame;
  List<int> _generatedMain = [];
  List<int> _generatedExtra = [];
  bool _animating = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _generate() async {
    if (_selectedGame == null) return;

    setState(() => _animating = true);
    HapticFeedback.mediumImpact();

    // Quick shuffle animation
    final random = Random();
    for (int i = 0; i < 8; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;
      setState(() {
        _generatedMain = _generateNumbers(
          _selectedGame!.mainNumbers,
          _selectedGame!.mainNumbersMax,
          random,
        );
        if (_selectedGame!.extraNumbers != null) {
          _generatedExtra = _generateNumbers(
            _selectedGame!.extraNumbers!,
            _selectedGame!.extraNumbersMax!,
            random,
          );
        }
      });
    }

    // Final numbers
    setState(() {
      _generatedMain = _generateNumbers(
        _selectedGame!.mainNumbers,
        _selectedGame!.mainNumbersMax,
        random,
      );
      _generatedMain.sort();
      if (_selectedGame!.extraNumbers != null) {
        _generatedExtra = _generateNumbers(
          _selectedGame!.extraNumbers!,
          _selectedGame!.extraNumbersMax!,
          random,
        );
        _generatedExtra.sort();
      } else {
        _generatedExtra = [];
      }
      _animating = false;
    });

    HapticFeedback.heavyImpact();
  }

  List<int> _generateNumbers(int count, int max, Random random) {
    if (max > 1000) {
      // For Lotería Nacional type (5 digit number)
      return [random.nextInt(max + 1)];
    }
    final numbers = <int>{};
    while (numbers.length < count) {
      numbers.add(random.nextInt(max) + 1);
    }
    return numbers.toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Game selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.casino, color: AppTheme.primary),
                      SizedBox(width: 8),
                      Text(
                        'Generador Aleatorio',
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
                            g.category != GameCategory.extraordinarios &&
                            g.id != 13) // Exclude Quiniela
                        .map((game) => DropdownMenuItem(
                              value: game,
                              child: Text('${game.icon} ${game.name}'),
                            ))
                        .toList(),
                    onChanged: (game) {
                      setState(() {
                        _selectedGame = game;
                        _generatedMain = [];
                        _generatedExtra = [];
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Generate button
          if (_selectedGame != null)
            ElevatedButton.icon(
              onPressed: _animating ? null : _generate,
              icon: AnimatedRotation(
                turns: _animating ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                child: const Icon(Icons.refresh, size: 28),
              ),
              label: Text(
                _animating ? 'Generando...' : 'Generar Números',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: AppTheme.primary,
              ),
            ),

          const SizedBox(height: 24),

          // Generated numbers
          if (_generatedMain.isNotEmpty) _buildGeneratedNumbers(),
        ],
      ),
    );
  }

  Widget _buildGeneratedNumbers() {
    final game = _selectedGame!;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              '${game.icon} ${game.name}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 20),

            // Main numbers
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: _generatedMain.map((n) {
                final display = game.mainNumbersMax > 1000
                    ? n.toString().padLeft(5, '0')
                    : n.toString();
                return NumberBall(
                  number: display,
                  color: AppTheme.primary,
                  size: game.mainNumbersMax > 1000 ? 80 : 52,
                );
              }).toList(),
            ),

            // Extra numbers
            if (_generatedExtra.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 1,
                    color: Colors.grey[300],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      game.extraNumbersLabel ?? 'Extra',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 1,
                    color: Colors.grey[300],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                alignment: WrapAlignment.center,
                children: _generatedExtra
                    .map((n) => NumberBall(
                          number: n.toString(),
                          color: AppTheme.secondary,
                          textColor: AppTheme.primaryDark,
                          size: 48,
                        ))
                    .toList(),
              ),
            ],

            const SizedBox(height: 20),

            // Copy / Share
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    final text = _formatNumbers();
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Números copiados'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copiar'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _generate,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Otra vez'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumbers() {
    final game = _selectedGame!;
    final mainStr = _generatedMain.map((n) {
      return game.mainNumbersMax > 1000
          ? n.toString().padLeft(5, '0')
          : n.toString();
    }).join(', ');

    if (_generatedExtra.isEmpty) return '${game.name}: $mainStr';
    final extraStr = _generatedExtra.join(', ');
    return '${game.name}: $mainStr | ${game.extraNumbersLabel}: $extraStr';
  }
}

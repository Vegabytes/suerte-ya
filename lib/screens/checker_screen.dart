import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/lottery_game.dart';
import '../services/lottery_service.dart';
import '../services/prize_checker_service.dart';
import '../widgets/number_ball.dart';

class CheckerScreen extends StatefulWidget {
  const CheckerScreen({super.key});

  @override
  State<CheckerScreen> createState() => _CheckerScreenState();
}

class _CheckerScreenState extends State<CheckerScreen> {
  final LotteryService _lotteryService = LotteryService();
  final PrizeCheckerService _prizeChecker = PrizeCheckerService();

  LotteryGame? _selectedGame;
  List<int> _selectedMainNumbers = [];
  List<int> _selectedExtraNumbers = [];
  List<PrizeMatch> _results = [];
  bool _checking = false;
  bool _hasChecked = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Game selector
          _buildGameSelector(),
          const SizedBox(height: 20),

          // Number input
          if (_selectedGame != null) ...[
            _buildNumberInput(),
            const SizedBox(height: 20),
            _buildCheckButton(),
          ],

          // Results
          if (_hasChecked) ...[
            const SizedBox(height: 24),
            _buildResults(),
          ],
        ],
      ),
    );
  }

  Widget _buildGameSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecciona el juego',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<LotteryGame>(
              initialValue: _selectedGame,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              hint: const Text('Elige un juego'),
              items: LotteryGame.allGames
                  .where((g) => g.category != GameCategory.extraordinarios)
                  .map((game) => DropdownMenuItem(
                        value: game,
                        child: Text('${game.icon} ${game.name}'),
                      ))
                  .toList(),
              onChanged: (game) {
                setState(() {
                  _selectedGame = game;
                  _selectedMainNumbers = [];
                  _selectedExtraNumbers = [];
                  _results = [];
                  _hasChecked = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberInput() {
    final game = _selectedGame!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tus números (${_selectedMainNumbers.length}/${game.mainNumbers})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Selected numbers display
            if (_selectedMainNumbers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _selectedMainNumbers
                      .map((n) => GestureDetector(
                            onTap: () => setState(() => _selectedMainNumbers.remove(n)),
                            child: NumberBall(
                              number: n.toString(),
                              color: AppTheme.primary,
                              size: 40,
                            ),
                          ))
                      .toList(),
                ),
              ),

            // Number grid
            _buildNumberGrid(
              max: game.mainNumbersMax,
              selected: _selectedMainNumbers,
              maxSelection: game.mainNumbers,
              onTap: (n) {
                setState(() {
                  if (_selectedMainNumbers.contains(n)) {
                    _selectedMainNumbers.remove(n);
                  } else if (_selectedMainNumbers.length < game.mainNumbers) {
                    _selectedMainNumbers.add(n);
                  }
                });
              },
            ),

            // Extra numbers
            if (game.extraNumbers != null && game.extraNumbersMax != null) ...[
              const SizedBox(height: 16),
              Text(
                '${game.extraNumbersLabel ?? "Extra"} (${_selectedExtraNumbers.length}/${game.extraNumbers})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildNumberGrid(
                max: game.extraNumbersMax!,
                selected: _selectedExtraNumbers,
                maxSelection: game.extraNumbers!,
                isExtra: true,
                onTap: (n) {
                  setState(() {
                    if (_selectedExtraNumbers.contains(n)) {
                      _selectedExtraNumbers.remove(n);
                    } else if (_selectedExtraNumbers.length < game.extraNumbers!) {
                      _selectedExtraNumbers.add(n);
                    }
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNumberGrid({
    required int max,
    required List<int> selected,
    required int maxSelection,
    bool isExtra = false,
    required Function(int) onTap,
  }) {
    // For large number ranges (like Lotería Nacional), show a text field instead
    if (max > 50) {
      return TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          hintText: 'Introduce tu número',
          prefixIcon: const Icon(Icons.dialpad),
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          final num = int.tryParse(value);
          if (num != null && num >= 0 && num <= max) {
            setState(() {
              selected.clear();
              selected.add(num);
            });
          }
        },
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(max, (i) {
        final number = i + (max <= 12 ? 0 : 1); // 0-based for reintegro, 1-based for numbers
        if (number > max) return const SizedBox.shrink();
        final isSelected = selected.contains(number);
        return GestureDetector(
          onTap: () => onTap(number),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? (isExtra ? AppTheme.secondary : AppTheme.primary)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? (isExtra ? AppTheme.secondaryDark : AppTheme.primaryDark)
                    : Colors.grey[300]!,
              ),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isSelected
                      ? (isExtra ? AppTheme.primaryDark : Colors.white)
                      : Colors.grey[700],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCheckButton() {
    final game = _selectedGame!;
    final canCheck = _selectedMainNumbers.length == game.mainNumbers;

    return ElevatedButton.icon(
      onPressed: canCheck ? _checkNumbers : null,
      icon: _checking
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : const Icon(Icons.search),
      label: Text(_checking ? 'Comprobando...' : 'Comprobar'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: canCheck ? AppTheme.primary : Colors.grey,
      ),
    );
  }

  Future<void> _checkNumbers() async {
    setState(() => _checking = true);

    try {
      final result = await _lotteryService.getLatestResult(_selectedGame!.id);
      if (result != null && mounted) {
        final matches = _prizeChecker.checkNumbers(
          gameId: _selectedGame!.id,
          userMainNumbers: _selectedMainNumbers,
          userExtraNumbers: _selectedExtraNumbers,
          result: result,
        );
        setState(() {
          _results = matches;
          _hasChecked = true;
          _checking = false;
        });
      } else {
        if (mounted) {
          setState(() => _checking = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudieron obtener los resultados')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _checking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al comprobar')),
        );
      }
    }
  }

  Widget _buildResults() {
    if (_results.isEmpty) {
      return Card(
        color: Colors.grey[50],
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.sentiment_neutral, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'Sin premio esta vez',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4),
              Text(
                '¡Sigue intentándolo!',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: AppTheme.success.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.celebration, size: 48, color: AppTheme.success),
            const SizedBox(height: 12),
            const Text(
              '¡Enhorabuena!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.success,
              ),
            ),
            const SizedBox(height: 16),
            ...(_results.map((match) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.success,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          match.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(match.description)),
                    ],
                  ),
                ))),
          ],
        ),
      ),
    );
  }
}

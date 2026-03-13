import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/lottery_service.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final LotteryService _lotteryService = LotteryService();
  final _codeController = TextEditingController();
  bool _checking = false;
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _checkCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _checking = true;
      _result = null;
      _error = null;
    });

    try {
      final result = await _lotteryService.checkSelaeTicket(code);
      if (mounted) {
        setState(() {
          _result = result;
          _checking = false;
          if (result == null) _error = 'No se pudo comprobar el código';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _checking = false;
          _error = 'Error de conexión. Inténtalo de nuevo.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear Boleto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Camera placeholder
            Card(
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[100],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'Escáner de cámara',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Próximamente - Escanea QR y códigos de barras',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Manual code input
            const Text(
              'O introduce el código manualmente',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                hintText: 'Código del boleto (20 dígitos)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.qr_code),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _codeController.clear();
                    setState(() {
                      _result = null;
                      _error = null;
                    });
                  },
                ),
              ),
              keyboardType: TextInputType.number,
              maxLength: 20,
              onSubmitted: (_) => _checkCode(),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _checking ? null : _checkCode,
              icon: _checking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(_checking ? 'Comprobando...' : 'Comprobar Boleto'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 24),

            // Result
            if (_error != null)
              Card(
                color: AppTheme.error.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppTheme.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(_error!,
                            style: const TextStyle(color: AppTheme.error)),
                      ),
                    ],
                  ),
                ),
              ),

            if (_result != null) _buildTicketResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketResult() {
    final premio = _result!['premio'];
    final hasPrize = premio != null && premio != 0 && premio != '0';

    return Card(
      color: hasPrize
          ? AppTheme.success.withValues(alpha: 0.1)
          : Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              hasPrize ? Icons.celebration : Icons.sentiment_neutral,
              size: 48,
              color: hasPrize ? AppTheme.success : Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              hasPrize ? '¡Premiado!' : 'Sin premio',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: hasPrize ? AppTheme.success : Colors.grey,
              ),
            ),
            if (hasPrize) ...[
              const SizedBox(height: 8),
              Text(
                '$premio€',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.success,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

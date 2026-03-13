import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/draw_result.dart';
import '../models/jackpot.dart';

class LotteryService {
  // SELAE (Loterías y Apuestas del Estado) endpoints
  static const String _selaeBaseUrl = 'https://www.loteriasyapuestas.es/servicios';
  // ONCE endpoints
  static const String _onceBaseUrl = 'https://www.once.es';

  // --- SELAE Results ---

  /// Fetches latest results for a SELAE game
  Future<DrawResult?> getSelaeResult(int gameId, {DateTime? date}) async {
    try {
      final gameCode = _selaeGameCode(gameId);
      if (gameCode == null) return null;

      final dateStr = date != null
          ? '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}'
          : '';

      final url = dateStr.isEmpty
          ? '$_selaeBaseUrl/ultimoResultado?juego=$gameCode'
          : '$_selaeBaseUrl/resultados?juego=$gameCode&fecha=$dateStr';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return _parseSelaeResult(gameId, response.body);
      }
    } catch (e) {
      // Log error, return null
    }
    return null;
  }

  /// Fetches latest jackpots from SELAE
  Future<List<Jackpot>> getSelaeJackpots() async {
    try {
      final response = await http.get(
        Uri.parse('$_selaeBaseUrl/botes'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return _parseSelaeJackpots(response.body);
      }
    } catch (e) {
      // Log error
    }
    return [];
  }

  /// Checks a SELAE ticket by its number/code
  Future<Map<String, dynamic>?> checkSelaeTicket(String code) async {
    try {
      final response = await http.get(
        Uri.parse('$_selaeBaseUrl/premioDecimoWeb?codigo=$code'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      // Log error
    }
    return null;
  }

  // --- ONCE Results ---

  Future<DrawResult?> getOnceResult(int gameId, {DateTime? date}) async {
    try {
      final gameCode = _onceGameCode(gameId);
      if (gameCode == null) return null;

      final dateStr = date != null
          ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
          : '';

      // ONCE provides results via their public JSON endpoints
      final url = dateStr.isEmpty
          ? '$_onceBaseUrl/servicios/resultado-sorteo/$gameCode/ultimo'
          : '$_onceBaseUrl/servicios/resultado-sorteo/$gameCode/fecha/$dateStr';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return _parseOnceResult(gameId, response.body);
      }
    } catch (e) {
      // Log error
    }
    return null;
  }

  // --- Generic fetcher ---

  Future<DrawResult?> getLatestResult(int gameId) async {
    if (_isSelaeGame(gameId)) {
      return getSelaeResult(gameId);
    } else if (_isOnceGame(gameId)) {
      return getOnceResult(gameId);
    }
    return null;
  }

  Future<List<DrawResult>> getAllLatestResults() async {
    final selaeIds = [1, 2, 3, 9, 14, 38];
    final onceIds = [10, 11, 27];

    final futures = <Future<DrawResult?>>[];

    for (final id in selaeIds) {
      futures.add(getSelaeResult(id));
    }
    for (final id in onceIds) {
      futures.add(getOnceResult(id));
    }

    final results = await Future.wait(futures);
    return results.whereType<DrawResult>().toList();
  }

  // --- Helpers ---

  bool _isSelaeGame(int id) => [1, 2, 3, 9, 13, 14, 16, 17, 18, 38].contains(id);
  bool _isOnceGame(int id) => [10, 11, 12, 19, 22, 27, 35, 36].contains(id);

  String? _selaeGameCode(int id) {
    const codes = {
      1: 'LAPR',
      2: 'BONO',
      3: 'ELGR',
      9: 'LNAC',
      13: 'LAQU',
      14: 'EURO',
      16: 'LOTU',
      17: 'QUPL',
      18: 'QGOL',
      38: 'EDMS',
    };
    return codes[id];
  }

  String? _onceGameCode(int id) {
    const codes = {
      10: 'cupon',
      11: 'cuponazo',
      12: 'finde',
      19: 'super7-39',
      22: 'superonce',
      27: 'eurojackpot',
      35: 'triplex',
      36: 'midia',
    };
    return codes[id];
  }

  DrawResult? _parseSelaeResult(int gameId, String body) {
    try {
      final data = json.decode(body);
      if (data == null) return null;

      // SELAE returns different formats per game, normalize them
      final Map<String, dynamic> resultData =
          data is List ? (data.isNotEmpty ? data[0] : {}) : data;

      final mainNumbers = <ResultNumber>[];
      final extraNumbers = <ResultNumber>[];
      final prizes = <Prize>[];

      // Parse combination
      if (resultData.containsKey('combinacion')) {
        final combo = resultData['combinacion'] as String? ?? '';
        final parts = combo.split(' - ');
        if (parts.isNotEmpty) {
          for (final n in parts[0].split(' ')) {
            if (n.trim().isNotEmpty) {
              mainNumbers.add(ResultNumber(value: n.trim()));
            }
          }
        }
      }

      // Parse complementario/reintegro
      if (resultData.containsKey('complementario')) {
        extraNumbers.add(ResultNumber(
          value: resultData['complementario'].toString(),
          label: 'Complementario',
        ));
      }
      if (resultData.containsKey('reintegro')) {
        extraNumbers.add(ResultNumber(
          value: resultData['reintegro'].toString(),
          label: 'Reintegro',
        ));
      }
      if (resultData.containsKey('estrellas')) {
        final stars = resultData['estrellas'] as String? ?? '';
        for (final s in stars.split(' ')) {
          if (s.trim().isNotEmpty) {
            extraNumbers.add(ResultNumber(value: s.trim(), label: 'Estrella'));
          }
        }
      }

      // Parse prizes
      if (resultData.containsKey('escrutinio')) {
        final scrutiny = resultData['escrutinio'] as List<dynamic>? ?? [];
        for (final p in scrutiny) {
          prizes.add(Prize(
            category: (p['tipo'] ?? p['categoria'] ?? '').toString(),
            description: (p['descripcion'] ?? '').toString(),
            winners: int.tryParse((p['ganadores'] ?? '0').toString()),
            amount: double.tryParse(
                (p['premio'] ?? p['importeEuros'] ?? '0').toString()),
          ));
        }
      }

      return DrawResult(
        gameId: gameId,
        gameName: resultData['nombre'] as String? ?? '',
        date: DateTime.tryParse(
                (resultData['fecha_sorteo'] ?? resultData['fecha'] ?? '')
                    .toString()) ??
            DateTime.now(),
        drawNumber:
            int.tryParse((resultData['numero'] ?? '').toString()),
        mainNumbers: mainNumbers,
        extraNumbers: extraNumbers,
        prizes: prizes,
        joker: resultData['joker']?.toString(),
      );
    } catch (e) {
      return null;
    }
  }

  DrawResult? _parseOnceResult(int gameId, String body) {
    try {
      final data = json.decode(body);
      if (data == null) return null;

      final mainNumbers = <ResultNumber>[];
      final extraNumbers = <ResultNumber>[];
      final prizes = <Prize>[];

      // ONCE games typically return numero premiado + serie
      if (data.containsKey('numeroPremiado')) {
        mainNumbers.add(ResultNumber(value: data['numeroPremiado'].toString()));
      }
      if (data.containsKey('serie')) {
        extraNumbers.add(ResultNumber(
          value: data['serie'].toString(),
          label: 'Serie',
        ));
      }

      // Parse premios
      if (data.containsKey('premios')) {
        final premiosList = data['premios'] as List<dynamic>? ?? [];
        for (final p in premiosList) {
          prizes.add(Prize(
            category: (p['categoria'] ?? '').toString(),
            description: (p['descripcion'] ?? '').toString(),
            winners: int.tryParse((p['ganadores'] ?? '0').toString()),
            amount: double.tryParse((p['importe'] ?? '0').toString()),
          ));
        }
      }

      return DrawResult(
        gameId: gameId,
        gameName: data['nombre'] as String? ?? '',
        date: DateTime.tryParse(
                (data['fecha'] ?? '').toString()) ??
            DateTime.now(),
        mainNumbers: mainNumbers,
        extraNumbers: extraNumbers,
        prizes: prizes,
      );
    } catch (e) {
      return null;
    }
  }

  List<Jackpot> _parseSelaeJackpots(String body) {
    try {
      final data = json.decode(body);
      if (data == null || data is! List) return [];

      return data.map<Jackpot>((item) {
        final gameCode = item['juego'] as String? ?? '';
        return Jackpot(
          gameId: _gameIdFromSelaeCode(gameCode),
          gameName: item['nombre'] as String? ?? '',
          amount: double.tryParse((item['bote'] ?? '0').toString()) ?? 0,
          nextDraw: DateTime.tryParse(
                  (item['fecha'] ?? '').toString()) ??
              DateTime.now(),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  int _gameIdFromSelaeCode(String code) {
    const ids = {
      'LAPR': 1,
      'BONO': 2,
      'ELGR': 3,
      'LNAC': 9,
      'LAQU': 13,
      'EURO': 14,
      'LOTU': 16,
      'QUPL': 17,
      'QGOL': 18,
      'EDMS': 38,
    };
    return ids[code] ?? 0;
  }
}

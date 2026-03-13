import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/draw_result.dart';

class StorageService {
  static const String _favoritesKey = 'favorites';
  static const String _cachedResultsKey = 'cached_results';
  static const String _userBetsKey = 'user_bets';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Favorites ---

  List<int> getFavorites() {
    final data = _prefs.getStringList(_favoritesKey);
    return data?.map((e) => int.parse(e)).toList() ?? [];
  }

  Future<void> toggleFavorite(int gameId) async {
    final favs = getFavorites();
    if (favs.contains(gameId)) {
      favs.remove(gameId);
    } else {
      favs.add(gameId);
    }
    await _prefs.setStringList(
        _favoritesKey, favs.map((e) => e.toString()).toList());
  }

  bool isFavorite(int gameId) => getFavorites().contains(gameId);

  // --- Cached Results ---

  Future<void> cacheResult(DrawResult result) async {
    final cached = getCachedResults();
    cached.removeWhere((r) => r.gameId == result.gameId);
    cached.add(result);
    await _prefs.setString(
      _cachedResultsKey,
      json.encode(cached.map((r) => r.toJson()).toList()),
    );
  }

  List<DrawResult> getCachedResults() {
    final data = _prefs.getString(_cachedResultsKey);
    if (data == null) return [];
    try {
      final list = json.decode(data) as List<dynamic>;
      return list
          .map((e) => DrawResult.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // --- User Bets ---

  Future<void> saveBet(Map<String, dynamic> bet) async {
    final bets = getBets();
    bet['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    bets.add(bet);
    await _prefs.setString(_userBetsKey, json.encode(bets));
  }

  Future<void> deleteBet(String betId) async {
    final bets = getBets();
    bets.removeWhere((b) => b['id'] == betId);
    await _prefs.setString(_userBetsKey, json.encode(bets));
  }

  List<Map<String, dynamic>> getBets() {
    final data = _prefs.getString(_userBetsKey);
    if (data == null) return [];
    try {
      final list = json.decode(data) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }
}

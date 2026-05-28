import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/forecast.dart';

class ForecastService {
  static const _hostBase = 'https://test-b30a4.web.app/regions';
  static const _cachePrefix = 'forecast_cache.v1.';
  static const _cacheTimePrefix = 'forecast_cache_at.v1.';

  Uri urlFor(String region) {
    return Uri.parse('$_hostBase/${Uri.encodeComponent(region)}.json');
  }

  Future<Forecast> fetch(String region, {bool useCache = true}) async {
    if (useCache) {
      final cached = await loadCached(region);
      if (cached != null) {
        unawaited(_refreshInBackground(region));
        return cached;
      }
    }
    return _fetchAndCache(region);
  }

  Future<Forecast?> loadCached(String region) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_cachePrefix$region');
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return Forecast.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<DateTime?> cachedAt(String region) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_cacheTimePrefix$region');
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> _refreshInBackground(String region) async {
    try {
      await _fetchAndCache(region);
    } catch (_) {
      // 백그라운드 새로고침 실패는 무시
    }
  }

  Future<Forecast> _fetchAndCache(String region) async {
    final res = await http.get(urlFor(region));
    if (res.statusCode != 200) {
      throw Exception('예보 데이터를 가져오지 못했습니다. (HTTP ${res.statusCode})');
    }
    final body = utf8.decode(res.bodyBytes);
    final map = jsonDecode(body) as Map<String, dynamic>;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_cachePrefix$region', body);
    await prefs.setString(
      '$_cacheTimePrefix$region',
      DateTime.now().toIso8601String(),
    );
    return Forecast.fromJson(map);
  }
}

void unawaited(Future<void> future) {}

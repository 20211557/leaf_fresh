import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/forecast.dart';

class ForecastService {
  static const _hostBase = 'https://test-b30a4.web.app/regions';
  static const _cachePrefix = 'forecast_cache.v1.';
  static const _cacheTimePrefix = 'forecast_cache_at.v1.';

  /// 매일 이 시각(현지 기준)이 지나면 JSON 을 새로 받아야 한다고 본다.
  /// 서버가 매일 오전 5시에 신규 데이터를 발행하는 일정과 맞춤.
  static const int dailyRefreshHour = 5;

  Uri urlFor(String region) {
    return Uri.parse('$_hostBase/${Uri.encodeComponent(region)}.json');
  }

  /// 마지막 fetch 가 "최근 daily refresh 시각" 보다 이전이면 stale.
  ///
  /// 예) 지금이 06:30 → 오늘 05:00 이후에 받았어야 함
  ///     지금이 03:00 → 어제 05:00 이후에 받았어야 함
  Future<bool> isStale(String region) async {
    final at = await cachedAt(region);
    if (at == null) return true;
    return at.isBefore(_lastRefreshBoundary());
  }

  /// 현재 시각 기준 "직전 5시"의 DateTime.
  /// 지금이 5시 이전이면 어제의 5시, 5시 이후면 오늘의 5시.
  DateTime _lastRefreshBoundary({DateTime? now}) {
    final n = now ?? DateTime.now();
    final today = DateTime(n.year, n.month, n.day, dailyRefreshHour);
    return n.isBefore(today) ? today.subtract(const Duration(days: 1)) : today;
  }

  /// 다음 5시까지 남은 Duration. UI 에 "다음 갱신 예정" 같은 메시지에 사용 가능.
  Duration timeUntilNextRefresh({DateTime? now}) {
    final n = now ?? DateTime.now();
    final last = _lastRefreshBoundary(now: n);
    final next = last.add(const Duration(days: 1));
    return next.difference(n);
  }

  /// 캐시 + 5시 경계 기반 fetch.
  ///
  /// 동작 순서:
  /// 1. `useCache: false` → 무조건 네트워크에서 받음 (수동 새로고침)
  /// 2. 캐시 없음 → 네트워크에서 받음
  /// 3. 캐시 있음 + stale (5시 경계 지남) → 네트워크 우선, 실패 시 캐시 fallback
  /// 4. 캐시 있음 + fresh → 캐시 즉시 반환 + 백그라운드 갱신 (cache-aside)
  Future<Forecast> fetch(String region, {bool useCache = true}) async {
    if (!useCache) return _fetchAndCache(region);

    final cached = await loadCached(region);
    if (cached == null) return _fetchAndCache(region);

    if (await isStale(region)) {
      try {
        return await _fetchAndCache(region);
      } catch (_) {
        // 네트워크 실패 시에는 옛 캐시라도 보여준다
        return cached;
      }
    }

    unawaited(_refreshInBackground(region));
    return cached;
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

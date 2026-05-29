import 'package:flutter/material.dart';

import '../../models/forecast.dart';
import '../../models/user_settings.dart';
import '../../services/forecast_service.dart';
import '../../services/settings_service.dart';
import '../../theme/app_colors.dart';
import '../report/report_tab.dart';
import '../setup/setup_flow_screen.dart';
import 'coping_tab.dart';
import 'home_tab.dart';
import 'scout_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final SettingsService _settingsService = SettingsService();
  final ForecastService _forecastService = ForecastService();

  UserSettings? _settings;
  Forecast? _forecast;
  Object? _error;
  bool _loading = true;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 앱이 background → foreground 로 돌아올 때마다 5시 경계 확인.
  /// 사용자가 새벽 4시에 앱을 닫고 아침 6시에 열면 자동으로 새 데이터 받음.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshIfStale();
    }
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final settings = await _settingsService.load();
      if (settings == null) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SetupFlowScreen()),
        );
        return;
      }
      final forecast = await _forecastService.fetch(settings.region);
      if (!mounted) return;
      setState(() {
        _settings = settings;
        _forecast = forecast;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    final region = _settings?.region;
    if (region == null) return;
    try {
      final forecast = await _forecastService.fetch(region, useCache: false);
      if (!mounted) return;
      setState(() {
        _forecast = forecast;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  /// 5시 경계가 지났는데 마지막 fetch 가 그 전이면 조용히 새로고침.
  /// 캐시가 fresh 면 아무 일도 하지 않음 (네트워크 호출 없음).
  Future<void> _refreshIfStale() async {
    final region = _settings?.region;
    if (region == null) return;
    if (await _forecastService.isStale(region)) {
      await _refresh();
    }
  }

  Future<void> _resetSettings() async {
    await _settingsService.clear();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SetupFlowScreen()),
    );
  }

  void _goTo(int index) => setState(() => _tab = index);

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_settings == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('설정 정보를 불러올 수 없습니다.')),
      );
    }
    final settings = _settings!;
    final tabs = [
      HomeTab(
        settings: settings,
        forecast: _forecast,
        error: _error,
        onRefresh: _refresh,
        onResetSettings: _resetSettings,
        onOpenReport: () => _goTo(2),
      ),
      CopingTab(
        settings: settings,
        forecast: _forecast,
        onGoHome: () => _goTo(0),
      ),
      ReportTab(
        settings: settings,
        forecast: _forecast,
        error: _error,
        onRefresh: _refresh,
        onOpenCoping: () => _goTo(1),
      ),
      const ScoutTab(),
    ];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: IndexedStack(index: _tab, children: tabs)),
      bottomNavigationBar: _HomeNavBar(
        index: _tab,
        onChanged: _goTo,
      ),
    );
  }
}

class _HomeNavBar extends StatelessWidget {
  const _HomeNavBar({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: '홈',
                selected: index == 0,
                onTap: () => onChanged(0),
              ),
              _NavItem(
                icon: Icons.shield_outlined,
                activeIcon: Icons.shield,
                label: '대응방법',
                selected: index == 1,
                onTap: () => onChanged(1),
              ),
              _NavItem(
                icon: Icons.bar_chart_outlined,
                activeIcon: Icons.bar_chart,
                label: '리포트',
                selected: index == 2,
                onTap: () => onChanged(2),
              ),
              _NavItem(
                icon: Icons.search_outlined,
                activeIcon: Icons.search,
                label: '예찰 결과',
                selected: index == 3,
                onTap: () => onChanged(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textMuted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? activeIcon : icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

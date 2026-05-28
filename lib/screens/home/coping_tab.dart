import 'package:flutter/material.dart';

import '../../models/coping_models.dart';
import '../../models/forecast.dart';
import '../../models/user_settings.dart';
import '../../services/coping_recommender.dart';
import '../../theme/app_colors.dart';
import '../coping/checklist_screen.dart';
import '../coping/recommendation_screen.dart';

/// 대응방법 탭. 체크리스트 응답이 없으면 [ChecklistScreen], 있으면
/// [RecommendationScreen] 을 보여준다.
class CopingTab extends StatefulWidget {
  const CopingTab({
    super.key,
    required this.settings,
    required this.forecast,
    required this.onGoHome,
  });

  final UserSettings? settings;
  final Forecast? forecast;
  final VoidCallback onGoHome;

  @override
  State<CopingTab> createState() => _CopingTabState();
}

class _CopingTabState extends State<CopingTab> {
  CopingResult? _result;

  void _onSubmit(CopingChecklist answers) {
    final settings = widget.settings;
    final today = widget.forecast?.today;
    if (settings == null || today == null) {
      _showSnack('예보 데이터가 아직 준비되지 않았습니다.');
      return;
    }
    final result = CopingRecommender.recommend(
      settings: settings,
      today: today,
      checklist: answers,
    );
    setState(() {
      _result = result;
    });
  }

  void _onRetake() {
    setState(() {
      _result = null;
    });
  }

  void _showSnack(String text) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.settings == null) {
      return const _NotReady(message: '설정 정보를 먼저 완료해 주세요.');
    }
    if (widget.forecast == null) {
      return const _NotReady(message: '오늘의 예보 데이터를 불러오는 중입니다.');
    }
    if (_result == null) {
      return ChecklistScreen(
        settings: widget.settings!,
        forecast: widget.forecast,
        onComplete: _onSubmit,
        onBack: widget.onGoHome,
      );
    }
    return RecommendationScreen(
      result: _result!,
      onBack: _onRetake,
      onRetake: _onRetake,
      onGoHome: widget.onGoHome,
    );
  }
}

class _NotReady extends StatelessWidget {
  const _NotReady({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield_outlined,
                  color: AppColors.primaryDeep, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              '대응방법',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

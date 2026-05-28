import 'package:flutter/material.dart';

import '../../models/forecast.dart';
import '../../models/growth_stage.dart';
import '../../models/user_settings.dart';
import '../../theme/app_colors.dart';
import 'widgets/current_risk_card.dart';
import 'widgets/risk_outlook_list.dart';
import 'widgets/risk_trend_chart.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
    required this.settings,
    required this.forecast,
    required this.error,
    required this.onRefresh,
    required this.onResetSettings,
    required this.onOpenReport,
  });

  final UserSettings settings;
  final Forecast? forecast;
  final Object? error;
  final Future<void> Function() onRefresh;
  final VoidCallback onResetSettings;
  final VoidCallback onOpenReport;

  @override
  Widget build(BuildContext context) {
    final activeStage = GrowthStageCalculator.riceStages[
        GrowthStageCalculator.activeIndex(settings.transplantDate)];
    final today = forecast?.today;
    final trend = forecast == null
        ? const <Prediction>[]
        : forecast!.predictions.take(5).toList();
    final outlook = forecast?.predictions ?? const <Prediction>[];

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        children: [
          _Header(
            settings: settings,
            stageName: activeStage.name,
            onReset: onResetSettings,
          ),
          const SizedBox(height: 16),
          if (today == null)
            _LoadingOrError(error: error, onRetry: onRefresh)
          else ...[
            CurrentRiskCard(prediction: today),
            const SizedBox(height: 14),
            if (today.summary != null && today.summary!.isNotEmpty)
              _SummaryCard(
                summary: today.summary!,
                onTapReport: onOpenReport,
              ),
            const SizedBox(height: 14),
            if (trend.isNotEmpty) RiskTrendChart(predictions: trend),
            const SizedBox(height: 14),
            if (outlook.isNotEmpty) RiskOutlookList(predictions: outlook),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.settings,
    required this.stageName,
    required this.onReset,
  });

  final UserSettings settings;
  final String stageName;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.eco, color: AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${settings.crop}($stageName) - ${settings.disease}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDeep,
            ),
          ),
        ),
        IconButton(
          onPressed: onReset,
          icon: const Icon(Icons.wb_sunny_outlined,
              color: AppColors.primary, size: 22),
          tooltip: '설정 초기화',
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.summary,
    required this.onTapReport,
  });

  final String summary;
  final VoidCallback onTapReport;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '한 줄 요약',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            summary,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onTapReport,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('리포트 자세히 보기'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryDeep,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingOrError extends StatelessWidget {
  const _LoadingOrError({required this.error, required this.onRetry});

  final Object? error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    if (error == null) {
      return Container(
        height: 240,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: const CircularProgressIndicator(),
      );
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined,
              size: 32, color: AppColors.textSecondary),
          const SizedBox(height: 10),
          const Text(
            '예보 데이터를 불러오지 못했습니다.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$error',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}

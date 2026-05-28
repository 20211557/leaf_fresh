import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/forecast.dart';
import '../../models/growth_stage.dart';
import '../../models/user_settings.dart';
import '../../services/summary_resolver.dart';
import '../../theme/app_colors.dart';
import '../../theme/risk_palette.dart';
import 'widgets/report_card.dart';

class ReportTab extends StatelessWidget {
  const ReportTab({
    super.key,
    required this.settings,
    required this.forecast,
    required this.error,
    required this.onRefresh,
    required this.onOpenCoping,
  });

  final UserSettings settings;
  final Forecast? forecast;
  final Object? error;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenCoping;

  @override
  Widget build(BuildContext context) {
    final today = forecast?.today;
    if (today == null) {
      return _EmptyReport(error: error, onRetry: onRefresh);
    }

    final dateText = DateFormat('M월 d일', 'ko_KR').format(today.targetDate);
    final currentGrade = RiskPalette.fromGradeCode(today.grade);
    final gradeChange = today.gradeChange;

    // 한 줄 요약: JSON 의 summary 대신 로컬에 저장된 이앙일로 계산한 생육 단계를
    // 사용해 멘트 매트릭스(SummaryResolver)에서 텍스트를 만들어낸다.
    final localStageName = GrowthStageCalculator
        .riceStages[
            GrowthStageCalculator.activeIndex(settings.transplantDate)]
        .name;
    final topVarName = today.cards.isNotEmpty
        ? (today.cards.first.subtitle ?? today.cards.first.groupLabel)
        : null;
    final summaryText = SummaryResolver.resolve(
      summaryCode: today.summaryCode,
      stageName: localStageName,
      topVarName: topVarName,
    );

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          _ReportHeader(
            dateText: dateText,
            currentGrade: currentGrade,
            gradeChange: gradeChange,
          ),
          const SizedBox(height: 22),
          _OneLineSummary(
            summary: summaryText,
            emphasis: SummaryResolver.emphasisTerms(stageName: localStageName),
          ),
          const SizedBox(height: 16),
          ...List.generate(today.cards.length, (i) {
            final card = today.cards[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ReportCard(index: i + 1, card: card),
            );
          }),
          const SizedBox(height: 12),
          Center(
            child: Column(
              children: [
                const Text(
                  '어떻게 대응해야 할까요?',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: onOpenCoping,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryDeep,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: const Text(
                    '내 논에 맞는 방제 방법 보러 가기  →',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

class _ReportHeader extends StatelessWidget {
  const _ReportHeader({
    required this.dateText,
    required this.currentGrade,
    required this.gradeChange,
  });

  final String dateText;
  final RiskGrade currentGrade;
  final GradeChange? gradeChange;

  String _defaultHeadline() {
    if (gradeChange == null) return '오늘의 위험 등급';
    switch (gradeChange!.direction) {
      case GradeChangeDirection.up:
        return '위험 등급이 상승했어요';
      case GradeChangeDirection.down:
        return '위험 등급이 낮아졌어요';
      case GradeChangeDirection.same:
        return '위험 등급이 유지되고 있어요';
    }
  }

  @override
  Widget build(BuildContext context) {
    // JSON 의 grade_change.label 이 있으면 그대로 노출, 없으면 direction 으로 결정
    final label = gradeChange?.label;
    final headline =
        (label != null && label.isNotEmpty) ? label : _defaultHeadline();

    // 등급이 변한 경우(up/down)에만 from → to 칩을 보여준다.
    final showTransition = gradeChange != null && !gradeChange!.isSame;
    final fromGrade = gradeChange == null
        ? null
        : RiskPalette.fromGradeCode(gradeChange!.fromCode);
    final toGrade = gradeChange == null
        ? currentGrade
        : RiskPalette.fromGradeCode(gradeChange!.toCode);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            headline,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (showTransition && fromGrade != null) ...[
                _GradePill(grade: fromGrade),
                const SizedBox(width: 8),
                Icon(
                  gradeChange!.isUp
                      ? Icons.arrow_forward
                      : Icons.arrow_back,
                  color: AppColors.primaryDeep,
                  size: 22,
                ),
                const SizedBox(width: 8),
                _GradePill(grade: toGrade),
              ] else
                _GradePill(grade: toGrade),
            ],
          ),
        ],
      ),
    );
  }
}

class _GradePill extends StatelessWidget {
  const _GradePill({required this.grade});

  final RiskGrade grade;

  @override
  Widget build(BuildContext context) {
    final color = RiskPalette.color[grade]!;
    final bg = RiskPalette.background[grade]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        RiskPalette.label[grade]!,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
    );
  }
}

class _OneLineSummary extends StatelessWidget {
  const _OneLineSummary({required this.summary, this.emphasis = const []});

  final String summary;
  final List<String> emphasis;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            '한 줄 요약',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.45,
            ),
            children: _buildSpans(summary, emphasis),
          ),
        ),
      ],
    );
  }

  static List<TextSpan> _buildSpans(String text, List<String> terms) {
    final cleaned = terms.where((t) => t.isNotEmpty).toSet().toList();
    if (cleaned.isEmpty) return [TextSpan(text: text)];

    final spans = <TextSpan>[];
    var cursor = 0;
    while (cursor < text.length) {
      int hitIdx = -1;
      String? hitTerm;
      for (final term in cleaned) {
        final idx = text.indexOf(term, cursor);
        if (idx == -1) continue;
        if (hitIdx == -1 || idx < hitIdx) {
          hitIdx = idx;
          hitTerm = term;
        }
      }
      if (hitIdx == -1 || hitTerm == null) {
        spans.add(TextSpan(text: text.substring(cursor)));
        break;
      }
      if (hitIdx > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, hitIdx)));
      }
      spans.add(TextSpan(
        text: hitTerm,
        style: const TextStyle(
          color: _growthStageAccent,
          fontWeight: FontWeight.w800,
        ),
      ));
      cursor = hitIdx + hitTerm.length;
    }
    return spans;
  }
}

const _growthStageAccent = Color(0xFFE66457);

class _EmptyReport extends StatelessWidget {
  const _EmptyReport({required this.error, required this.onRetry});

  final Object? error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart_outlined,
                size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              error == null
                  ? '예보 데이터를 불러오는 중입니다.'
                  : '예보를 가져오지 못했습니다.\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}

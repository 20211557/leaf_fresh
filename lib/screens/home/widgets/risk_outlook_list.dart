import 'package:flutter/material.dart';

import '../../../models/forecast.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/risk_palette.dart';
import 'risk_trend_chart.dart';

class RiskOutlookList extends StatelessWidget {
  const RiskOutlookList({super.key, required this.predictions});

  final List<Prediction> predictions;

  @override
  Widget build(BuildContext context) {
    if (predictions.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 0, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 20),
            child: Text(
              '15일 위험도 전망',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 20),
              itemCount: predictions.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, i) => _OutlookCard(prediction: predictions[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlookCard extends StatelessWidget {
  const _OutlookCard({required this.prediction});

  final Prediction prediction;

  @override
  Widget build(BuildContext context) {
    final grade = RiskPalette.fromGradeCode(prediction.grade);
    final color = RiskPalette.color[grade]!;
    final bg = RiskPalette.background[grade]!;

    return Container(
      width: 84,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Text(
            '${prediction.targetDate.month}/${prediction.targetDate.day}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2A2A2A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            RiskTrendChart.weekdayOf(prediction.targetDate),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7A7A7A),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              RiskPalette.label[grade]!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

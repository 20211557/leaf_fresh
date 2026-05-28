import 'package:flutter/material.dart';

/// 예찰일(6-9월 1·16일) 홈 화면 메인 카드.
///
/// 도넛 위험도 게이지 대신 현장 실측 피해 면적율을 보여준다.
class ObservationResultCard extends StatelessWidget {
  const ObservationResultCard({
    super.key,
    required this.damageRate,
    required this.baselineRate,
  });

  /// 실측 피해 면적율 (0~1 비율). JSON `inputs.observed_damage_rate`.
  final double damageRate;

  /// 평년 베이스라인 (0~1 비율).
  final double baselineRate;

  static const _cardBg = Color(0xFFDDE8CD);
  static const _accentGreen = Color(0xFF5A8A40);
  static const _subText = Color(0xFF6F8462);
  static const _divider = Color(0xFFB8C6A6);
  static const _diffRed = Color(0xFFE25A4A);
  static const _diffGreen = Color(0xFF3FA862);

  @override
  Widget build(BuildContext context) {
    final diffPp = (damageRate - baselineRate) * 100;
    final isWorse = diffPp > 0.05;
    final isBetter = diffPp < -0.05;
    final diffColor = isWorse
        ? _diffRed
        : isBetter
            ? _diffGreen
            : _subText;
    final diffSign = isWorse ? '+' : isBetter ? '-' : '';
    final diffText = '$diffSign${diffPp.abs().toStringAsFixed(1)}%p';

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '오늘 예찰 결과',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _accentGreen,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                (damageRate * 100).toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1A1A),
                  height: 1.0,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  '%',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '피해 면적율',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _subText,
            ),
          ),
          const SizedBox(height: 18),
          const _DashedDivider(color: _divider),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.arrow_forward, color: diffColor, size: 18),
              const SizedBox(width: 10),
              const Text(
                '평년 대비',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                diffText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: diffColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const dashWidth = 5.0;
      const dashSpace = 4.0;
      final dashCount =
          (constraints.maxWidth / (dashWidth + dashSpace)).floor();
      return SizedBox(
        height: 1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            dashCount,
            (_) => SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            ),
          ),
        ),
      );
    });
  }
}

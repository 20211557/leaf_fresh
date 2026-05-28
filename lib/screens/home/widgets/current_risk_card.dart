import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../models/forecast.dart';
import '../../../theme/risk_palette.dart';

class CurrentRiskCard extends StatelessWidget {
  const CurrentRiskCard({super.key, required this.prediction});

  final Prediction prediction;

  @override
  Widget build(BuildContext context) {
    final score = prediction.riskScore100;
    final grade = RiskPalette.fromGradeCode(prediction.grade);
    final color = RiskPalette.color[grade]!;
    final bg = RiskPalette.background[grade]!;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              '현재 위험도',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: _RiskRing(
              score: score,
              grade: grade,
              color: color,
            ),
          ),
          const SizedBox(height: 18),
          _RiskScale(score: score),
        ],
      ),
    );
  }
}

class _RiskRing extends StatelessWidget {
  const _RiskRing({
    required this.score,
    required this.grade,
    required this.color,
  });

  final double score;
  final RiskGrade grade;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 198,
      height: 198,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(198, 198),
            painter: _RingPainter(
              value: (score / 100).clamp(0, 1).toDouble(),
              color: color,
              backgroundColor: Colors.white,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  RiskPalette.label[grade]!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    score.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      color: Color(0xFF2A2A2A),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6, left: 2),
                    child: Text(
                      '/100',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7A7A7A),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.color,
    required this.backgroundColor,
  });

  final double value;
  final Color color;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 16.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final sweep = 2 * math.pi * value;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.value != value || old.color != color;
}

class _RiskScale extends StatelessWidget {
  const _RiskScale({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      const safe = RiskPalette.safeMax;
      const caution = RiskPalette.cautionMax;
      const alert = RiskPalette.alertMax;
      final clamped = score.clamp(0, 100);
      final dotX = (clamped / 100) * (width - 16);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 18,
            child: Stack(
              children: [
                Row(
                  children: [
                    _ScaleSegment(
                      flex: (safe).toInt(),
                      color: RiskPalette.color[RiskGrade.safe]!,
                      isFirst: true,
                    ),
                    _ScaleSegment(
                      flex: (caution - safe).toInt(),
                      color: RiskPalette.color[RiskGrade.caution]!,
                    ),
                    _ScaleSegment(
                      flex: (alert - caution).toInt(),
                      color: RiskPalette.color[RiskGrade.alert]!,
                    ),
                    _ScaleSegment(
                      flex: (100 - alert).toInt(),
                      color: RiskPalette.color[RiskGrade.severe]!,
                      isLast: true,
                    ),
                  ],
                ),
                Positioned(
                  left: dotX,
                  top: -1,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: RiskPalette
                            .color[RiskPalette.fromScore100(clamped.toDouble())]!,
                        width: 3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Expanded(child: _Tick(value: '3', label: '안전', grade: RiskGrade.safe)),
              Expanded(child: _Tick(value: '16', label: '주의', grade: RiskGrade.caution)),
              Expanded(child: _Tick(value: '35', label: '경계', grade: RiskGrade.alert)),
              Expanded(child: _Tick(value: '100', label: '심각', grade: RiskGrade.severe)),
            ],
          ),
        ],
      );
    });
  }
}

class _ScaleSegment extends StatelessWidget {
  const _ScaleSegment({
    required this.flex,
    required this.color,
    this.isFirst = false,
    this.isLast = false,
  });

  final int flex;
  final Color color;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex.clamp(1, 200),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.55),
          borderRadius: BorderRadius.horizontal(
            left: isFirst ? const Radius.circular(6) : Radius.zero,
            right: isLast ? const Radius.circular(6) : Radius.zero,
          ),
        ),
      ),
    );
  }
}

class _Tick extends StatelessWidget {
  const _Tick({
    required this.value,
    required this.label,
    required this.grade,
  });

  final String value;
  final String label;
  final RiskGrade grade;

  @override
  Widget build(BuildContext context) {
    final color = RiskPalette.color[grade]!;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

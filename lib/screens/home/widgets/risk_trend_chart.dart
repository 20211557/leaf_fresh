import 'package:flutter/material.dart';

import '../../../models/forecast.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/risk_palette.dart';

class RiskTrendChart extends StatelessWidget {
  const RiskTrendChart({super.key, required this.predictions});

  final List<Prediction> predictions;

  static const _weekdayNames = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '위험도 추이 (향후 5일)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: CustomPaint(
              size: Size.infinite,
              painter: _ChartPainter(predictions: predictions),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _Legend(color: Color(0xFF67B864), label: '안전'),
              SizedBox(width: 10),
              _Legend(color: Color(0xFFF0C748), label: '주의'),
              SizedBox(width: 10),
              _Legend(color: Color(0xFFF4A150), label: '경계'),
              SizedBox(width: 10),
              _Legend(color: Color(0xFFE66457), label: '심각'),
            ],
          ),
        ],
      ),
    );
  }

  static String weekdayOf(DateTime d) {
    return _weekdayNames[(d.weekday - 1).clamp(0, 6)];
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: color, width: 2),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({required this.predictions});

  final List<Prediction> predictions;

  @override
  void paint(Canvas canvas, Size size) {
    if (predictions.isEmpty) return;

    final chartLeft = 8.0;
    final chartRight = size.width - 8;
    final chartTop = 8.0;
    final chartBottom = size.height - 40;
    final chartHeight = chartBottom - chartTop;
    final chartWidth = chartRight - chartLeft;

    double yFor(double score) {
      final ratio = (score / 100).clamp(0.0, 1.0);
      return chartBottom - ratio * chartHeight;
    }

    final bands = [
      (RiskGrade.severe, RiskPalette.alertMax, 100.0),
      (RiskGrade.alert, RiskPalette.cautionMax, RiskPalette.alertMax),
      (RiskGrade.caution, RiskPalette.safeMax, RiskPalette.cautionMax),
      (RiskGrade.safe, 0.0, RiskPalette.safeMax),
    ];
    for (final band in bands) {
      final paint = Paint()
        ..color = RiskPalette.background[band.$1]!.withValues(alpha: 0.7);
      final top = yFor(band.$3.toDouble());
      final bottom = yFor(band.$2.toDouble());
      canvas.drawRect(
        Rect.fromLTRB(chartLeft, top, chartRight, bottom),
        paint,
      );
    }

    final gridPaint = Paint()
      ..color = const Color(0xFFB6B6B6).withValues(alpha: 0.3)
      ..strokeWidth = 0.8;
    for (final v in [RiskPalette.safeMax, RiskPalette.cautionMax, RiskPalette.alertMax]) {
      final y = yFor(v.toDouble());
      _drawDashed(canvas, Offset(chartLeft, y), Offset(chartRight, y), gridPaint);
    }

    final stepCount = predictions.length;
    double xAt(int i) {
      if (stepCount <= 1) return chartLeft + chartWidth / 2;
      return chartLeft + (chartWidth / (stepCount - 1)) * i;
    }

    final linePaint = Paint()
      ..color = const Color(0xFFE66457)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (var i = 0; i < predictions.length; i++) {
      final p = predictions[i];
      final pt = Offset(xAt(i), yFor(p.riskScore100));
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    canvas.drawPath(path, linePaint);

    final textStyle = const TextStyle(
      color: Color(0xFF2A2A2A),
      fontSize: 12,
      fontWeight: FontWeight.w800,
    );
    final dateStyle = const TextStyle(
      color: Color(0xFF7A7A7A),
      fontSize: 11,
      fontWeight: FontWeight.w700,
    );
    final dowStyle = const TextStyle(
      color: Color(0xFFB6B6B6),
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );

    for (var i = 0; i < predictions.length; i++) {
      final p = predictions[i];
      final cx = xAt(i);
      final cy = yFor(p.riskScore100);

      final dotPaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(cx, cy), 5, dotPaint);
      final ringPaint = Paint()
        ..color = const Color(0xFFE66457)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(cx, cy), 5, ringPaint);

      final scoreTp = TextPainter(
        text: TextSpan(text: p.riskScore100.toStringAsFixed(0), style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      scoreTp.paint(canvas, Offset(cx - scoreTp.width / 2, cy - 22));

      final date = '${p.targetDate.month}/${p.targetDate.day}';
      final dateTp = TextPainter(
        text: TextSpan(text: date, style: dateStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      dateTp.paint(canvas, Offset(cx - dateTp.width / 2, chartBottom + 6));

      final dow = RiskTrendChart.weekdayOf(p.targetDate);
      final dowTp = TextPainter(
        text: TextSpan(text: dow, style: dowStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      dowTp.paint(canvas, Offset(cx - dowTp.width / 2, chartBottom + 22));
    }

    final hundredTp = TextPainter(
      text: const TextSpan(
        text: '100',
        style: TextStyle(
          color: Color(0xFF7A7A7A),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    hundredTp.paint(canvas, Offset(chartLeft + 2, chartTop - 4));
  }

  void _drawDashed(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dash = 4.0;
    const gap = 4.0;
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final dist = (dx * dx + dy * dy);
    final length = dist <= 0 ? 0 : (dx.abs() + dy.abs());
    final steps = length ~/ (dash + gap);
    if (steps == 0) {
      canvas.drawLine(start, end, paint);
      return;
    }
    final stepX = dx / steps;
    final stepY = dy / steps;
    var current = start;
    for (var i = 0; i < steps; i++) {
      final segEnd = Offset(
        current.dx + stepX * (dash / (dash + gap)),
        current.dy + stepY * (dash / (dash + gap)),
      );
      canvas.drawLine(current, segEnd, paint);
      current = Offset(current.dx + stepX, current.dy + stepY);
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) =>
      old.predictions != predictions;
}

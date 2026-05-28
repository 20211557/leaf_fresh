import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum SetupStepState { completed, current, upcoming }

class SetupStepData {
  final String label;
  final String? value;
  final SetupStepState state;

  const SetupStepData({
    required this.label,
    required this.state,
    this.value,
  });
}

class SetupStepIndicator extends StatelessWidget {
  const SetupStepIndicator({super.key, required this.steps});

  final List<SetupStepData> steps;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < steps.length; i++) {
      children.add(Expanded(child: _StepCell(index: i + 1, data: steps[i])));
      if (i < steps.length - 1) {
        final leftDone = steps[i].state == SetupStepState.completed;
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 36),
            child: SizedBox(
              width: 40,
              child: Container(
                height: 2,
                color: leftDone
                    ? AppColors.primaryDark
                    : AppColors.primaryLight.withValues(alpha: 0.7),
              ),
            ),
          ),
        );
      }
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }
}

class _StepCell extends StatelessWidget {
  const _StepCell({required this.index, required this.data});

  final int index;
  final SetupStepData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StepCircle(index: index, state: data.state),
        const SizedBox(height: 6),
        Text(
          data.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: data.state == SetupStepState.current
                ? FontWeight.w700
                : FontWeight.w500,
            color: data.state == SetupStepState.upcoming
                ? AppColors.textMuted
                : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 18,
          child: data.value == null
              ? null
              : Text(
                  data.value!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
        ),
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({required this.index, required this.state});

  final int index;
  final SetupStepState state;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case SetupStepState.completed:
        return Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 20, color: AppColors.primaryDeep),
        );
      case SetupStepState.current:
        return Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.primaryDark,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$index',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textOnPrimary,
            ),
          ),
        );
      case SetupStepState.upcoming:
        return DottedCircle(
          diameter: 36,
          color: AppColors.primaryLight,
          child: Text(
            '$index',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        );
    }
  }
}

class DottedCircle extends StatelessWidget {
  const DottedCircle({
    super.key,
    required this.diameter,
    required this.color,
    required this.child,
  });

  final double diameter;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedCirclePainter(color: color),
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: Center(child: child),
      ),
    );
  }
}

class _DottedCirclePainter extends CustomPainter {
  _DottedCirclePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    const dashCount = 24;
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final sweep = (2 * 3.141592653589793) / dashCount;
    for (var i = 0; i < dashCount; i++) {
      final start = i * sweep;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 1),
        start,
        sweep * 0.55,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DottedCirclePainter oldDelegate) =>
      oldDelegate.color != color;
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import 'setup_controller.dart';

class TransplantDateStep extends StatefulWidget {
  const TransplantDateStep({super.key, required this.draft});

  final SetupDraft draft;

  @override
  State<TransplantDateStep> createState() => _TransplantDateStepState();
}

class _TransplantDateStepState extends State<TransplantDateStep> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final initial = widget.draft.transplantDate ?? DateTime.now();
    _month = DateTime(initial.year, initial.month);
  }

  void _changeMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              _StepNumber('3'),
              SizedBox(width: 12),
              Text(
                '모를 언제 심으셨나요?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder),
            ),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            child: _Calendar(
              month: _month,
              selected: widget.draft.transplantDate,
              onSelect: widget.draft.setDate,
              onPrev: () => _changeMonth(-1),
              onNext: () => _changeMonth(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepNumber extends StatelessWidget {
  const _StepNumber(this.number);

  final String number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        number,
        style: const TextStyle(
          color: AppColors.textOnPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _Calendar extends StatelessWidget {
  const _Calendar({
    required this.month,
    required this.selected,
    required this.onSelect,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime month;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  static const _weekdays = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingEmpty = firstDayOfMonth.weekday % 7;
    final totalCells = leadingEmpty + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: onPrev,
              icon: const Icon(Icons.chevron_left),
              color: AppColors.textPrimary,
            ),
            Text(
              DateFormat('y년 M월', 'ko_KR').format(month),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            IconButton(
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right),
              color: AppColors.textPrimary,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(7, (i) {
            final isSun = i == 0;
            final isSat = i == 6;
            return Expanded(
              child: Center(
                child: Text(
                  _weekdays[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSun
                        ? AppColors.sundayRed
                        : isSat
                            ? AppColors.saturdayBlue
                            : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        ...List.generate(rows, (row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: List.generate(7, (col) {
                final index = row * 7 + col;
                final dayNum = index - leadingEmpty + 1;
                if (dayNum < 1 || dayNum > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 40));
                }
                final date = DateTime(month.year, month.month, dayNum);
                final isSelected = selected != null &&
                    selected!.year == date.year &&
                    selected!.month == date.month &&
                    selected!.day == date.day;
                final isSun = col == 0;
                final isSat = col == 6;
                return Expanded(
                  child: _DayCell(
                    day: dayNum,
                    selected: isSelected,
                    textColor: isSun
                        ? AppColors.sundayRed
                        : isSat
                            ? AppColors.saturdayBlue
                            : AppColors.textPrimary,
                    onTap: () => onSelect(date),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.selected,
    required this.textColor,
    required this.onTap,
  });

  final int day;
  final bool selected;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryDark : Colors.transparent,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 15,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected ? AppColors.textOnPrimary : textColor,
            ),
          ),
        ),
      ),
    );
  }
}

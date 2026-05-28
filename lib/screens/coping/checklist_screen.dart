import 'package:flutter/material.dart';

import '../../models/coping_models.dart';
import '../../models/forecast.dart';
import '../../models/growth_stage.dart';
import '../../models/user_settings.dart';
import '../../services/coping_catalog.dart';
import '../../theme/app_colors.dart';
import '../../theme/risk_palette.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({
    super.key,
    required this.settings,
    required this.forecast,
    required this.onComplete,
    required this.onBack,
  });

  final UserSettings settings;
  final Forecast? forecast;
  final ValueChanged<CopingChecklist> onComplete;
  final VoidCallback onBack;

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final CopingChecklist _draft = CopingChecklist();

  void _set(VoidCallback mutate) => setState(mutate);

  @override
  Widget build(BuildContext context) {
    final today = widget.forecast?.today;
    final stageName = GrowthStageCalculator
        .riceStages[
            GrowthStageCalculator.activeIndex(widget.settings.transplantDate)]
        .name;
    final grade = today == null
        ? RiskGrade.safe
        : RiskPalette.fromGradeCode(today.grade);
    final condition = today == null
        ? SprayCondition.goodVentilation
        : classifySprayCondition(
            windMs: today.inputs.windSpeedToday,
            rainMm: today.inputs.precipitationToday,
          );
    final scenario = resolveScenario(grade, condition);
    final drugCount = CopingCatalog.drugsFor(
      stageName: stageName,
      scenario: scenario,
    ).length;
    final nonDrugCount = CopingCatalog.nonDrugsFor(
      stageName: stageName,
      scenario: scenario,
    ).length;

    return Column(
      children: [
        _Header(onBack: widget.onBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: [
              _ContextCard(
                stageName: stageName,
                grade: grade,
                condition: condition,
                drugCount: drugCount,
                nonDrugCount: nonDrugCount,
              ),
              const SizedBox(height: 16),
              _ProgressBar(
                done: _draft.answeredCount,
                total: CopingChecklist.total,
              ),
              const SizedBox(height: 18),
              _QuestionBlock<EcoPreference>(
                id: 'S1',
                title: '친환경 농법을 선호하시나요?',
                hint: '친환경 인증 농가는 사용 가능한 약제가 제한돼요',
                value: _draft.s1,
                options: EcoPreference.values,
                labelOf: (v) => v.label,
                sublabelOf: (v) => v.hint,
                onChanged: (v) => _set(() => _draft.s1 = v),
              ),
              _QuestionBlock<DiseaseSpread>(
                id: 'S2',
                title: '현재 벼의 병반 상태는 어떤가요?',
                hint: '잎집 아래쪽부터 위쪽 잎까지 어디까지 번졌는지 확인하세요',
                value: _draft.s2,
                options: DiseaseSpread.values,
                labelOf: (v) => v.label,
                sublabelOf: (v) => v.tag,
                onChanged: (v) => _set(() => _draft.s2 = v),
              ),
              _QuestionBlock<SprayCount>(
                id: 'S3',
                title: '이번 시즌 동안 살균제를 몇 회 살포하셨나요?',
                hint: '연간 사용 한도가 있는 약제는 자동으로 제외돼요',
                value: _draft.s3,
                options: SprayCount.values,
                labelOf: (v) => v.label,
                onChanged: (v) => _set(() => _draft.s3 = v),
              ),
              _QuestionBlock<SprayEquipment>(
                id: 'S4',
                title: '어떤 살포 장비를 사용하시나요?',
                value: _draft.s4,
                options: SprayEquipment.values,
                labelOf: (v) => v.label,
                sublabelOf: (v) => v.hint,
                onChanged: (v) => _set(() => _draft.s4 = v),
              ),
              _QuestionBlock<WeatherForecastChoice>(
                id: 'S5',
                title: '향후 3일 강수 예보를 알고 계신가요?',
                hint: '비가 곧 오면 살포 효과가 떨어져요',
                value: _draft.s5,
                options: WeatherForecastChoice.values,
                labelOf: (v) => v.label,
                onChanged: (v) => _set(() => _draft.s5 = v),
              ),
              _QuestionBlock<HarvestRange>(
                id: 'S6',
                title: '수확 예정일은 언제인가요?',
                hint: '안전사용기준에 맞지 않는 약제는 자동으로 제외됩니다',
                value: _draft.s6,
                options: HarvestRange.values,
                labelOf: (v) => v.label,
                onChanged: (v) => _set(() => _draft.s6 = v),
              ),
              _QuestionBlock<NeighborSensitive>(
                id: 'S7',
                title: '인접한 양봉장이나 친환경 작물이 있나요?',
                hint: '비산 위험이 있는 약제는 사용을 피해야 해요',
                value: _draft.s7,
                options: NeighborSensitive.values,
                labelOf: (v) => v.label,
                onChanged: (v) => _set(() => _draft.s7 = v),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: _SubmitButton(
            remaining: _draft.remaining,
            enabled: _draft.isComplete,
            onSubmit: () => widget.onComplete(_draft),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 4),
          const Text(
            '방제 결정 지원',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextCard extends StatelessWidget {
  const _ContextCard({
    required this.stageName,
    required this.grade,
    required this.condition,
    required this.drugCount,
    required this.nonDrugCount,
  });

  final String stageName;
  final RiskGrade grade;
  final SprayCondition condition;
  final int drugCount;
  final int nonDrugCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _Pill(
                  icon: Icons.eco,
                  label: '생육시기',
                  value: stageName,
                  color: AppColors.primary,
                  bg: AppColors.primaryLight.withValues(alpha: 0.45),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Pill(
                  icon: Icons.warning_amber_rounded,
                  label: '위험등급',
                  value: RiskPalette.label[grade] ?? '-',
                  color: RiskPalette.color[grade]!,
                  bg: RiskPalette.background[grade]!,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Pill(
                  icon: Icons.opacity,
                  label: '살포여부',
                  value: condition.label,
                  color: const Color(0xFF3C7FB6),
                  bg: const Color(0xFFDDEBF7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '이 조건에서 사용 가능한 방법은 약제 $drugCount종 + 비약제 $nonDrugCount종입니다. 아래 질문에 답하면 가장 적절한 방법을 추천해드려요.',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.done, required this.total});
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : done / total;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '진행률',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '$done/$total 완료',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: AppColors.disabledBg,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionBlock<T> extends StatelessWidget {
  const _QuestionBlock({
    required this.id,
    required this.title,
    this.hint,
    required this.value,
    required this.options,
    required this.labelOf,
    this.sublabelOf,
    required this.onChanged,
  });

  final String id;
  final String title;
  final String? hint;
  final T? value;
  final List<T> options;
  final String Function(T) labelOf;
  final String Function(T)? sublabelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              id,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            if (hint != null) ...[
              const SizedBox(height: 4),
              Text(
                hint!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 8),
            ...options.map((opt) {
              final selected = value == opt;
              final sub = sublabelOf?.call(opt);
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _OptionRow(
                  label: labelOf(opt),
                  sublabel: sub,
                  selected: selected,
                  onTap: () => onChanged(opt),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.label,
    required this.selected,
    required this.onTap,
    this.sublabel,
  });

  final String label;
  final String? sublabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
              color:
                  selected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          selected ? FontWeight.w800 : FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (sublabel != null && sublabel!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      sublabel!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.remaining,
    required this.enabled,
    required this.onSubmit,
  });
  final int remaining;
  final bool enabled;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled ? onSubmit : null,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            enabled ? AppColors.primary : AppColors.disabledBg,
        foregroundColor:
            enabled ? AppColors.textOnPrimary : AppColors.disabledText,
      ),
      child: Text(enabled ? '추천 보기' : '$remaining개 항목이 남았습니다'),
    );
  }
}

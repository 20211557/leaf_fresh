import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'setup_controller.dart';

class _Crop {
  final String name;
  final String emoji;
  final bool available;
  final List<_Disease> diseases;
  const _Crop({
    required this.name,
    required this.emoji,
    required this.available,
    this.diseases = const [],
  });
}

class _Disease {
  final String name;
  final bool available;
  const _Disease(this.name, {this.available = false});
}

class CropSelectStep extends StatefulWidget {
  const CropSelectStep({super.key, required this.draft});

  final SetupDraft draft;

  @override
  State<CropSelectStep> createState() => _CropSelectStepState();
}

class _CropSelectStepState extends State<CropSelectStep> {
  static const List<_Crop> _crops = [
    _Crop(
      name: '벼',
      emoji: '🌾',
      available: true,
      diseases: [
        _Disease('잎집무늬마름병', available: true),
        _Disease('도열병'),
        _Disease('흰잎마름병'),
        _Disease('이삭누룩병'),
      ],
    ),
    _Crop(name: '콩', emoji: '🫘', available: false),
    _Crop(name: '옥수수', emoji: '🌽', available: false),
    _Crop(name: '감자', emoji: '🥔', available: false),
    _Crop(name: '고추', emoji: '🌶️', available: false),
  ];

  String _expandedCrop = '벼';

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              _StepNumber('2'),
              SizedBox(width: 12),
              Text(
                '작물과 병해충을 선택해주세요',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ..._crops.map((crop) => _CropBlock(
                crop: crop,
                expanded: _expandedCrop == crop.name,
                selectedDisease: draft.crop == crop.name ? draft.disease : null,
                onTapHeader: () {
                  if (!crop.available) return;
                  setState(() => _expandedCrop = crop.name);
                },
                onSelectDisease: (disease) {
                  draft.setCropDisease(crop: crop.name, disease: disease);
                },
              )),
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

class _CropBlock extends StatelessWidget {
  const _CropBlock({
    required this.crop,
    required this.expanded,
    required this.selectedDisease,
    required this.onTapHeader,
    required this.onSelectDisease,
  });

  final _Crop crop;
  final bool expanded;
  final String? selectedDisease;
  final VoidCallback onTapHeader;
  final ValueChanged<String> onSelectDisease;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          _CropHeader(crop: crop, expanded: expanded, onTap: onTapHeader),
          if (expanded && crop.available) ...[
            const SizedBox(height: 12),
            _DiseaseGrid(
              diseases: crop.diseases,
              selected: selectedDisease,
              onSelect: onSelectDisease,
            ),
          ],
        ],
      ),
    );
  }
}

class _CropHeader extends StatelessWidget {
  const _CropHeader({
    required this.crop,
    required this.expanded,
    required this.onTap,
  });

  final _Crop crop;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = crop.available && expanded;
    final bg = isActive
        ? AppColors.primary
        : crop.available
            ? AppColors.surface
            : AppColors.disabledBg;
    final textColor = isActive
        ? AppColors.textOnPrimary
        : crop.available
            ? AppColors.textPrimary
            : AppColors.disabledText;

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isActive ? AppColors.primary : AppColors.cardBorder,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: crop.available ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primaryLight.withValues(alpha: 0.7)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(crop.emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crop.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    if (!crop.available)
                      const Text(
                        '향후 지원 예정',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.disabledText,
                        ),
                      ),
                  ],
                ),
              ),
              if (crop.available)
                Icon(
                  expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: textColor,
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '준비 중',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.disabledText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiseaseGrid extends StatelessWidget {
  const _DiseaseGrid({
    required this.diseases,
    required this.selected,
    required this.onSelect,
  });

  final List<_Disease> diseases;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: diseases.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.6,
      ),
      itemBuilder: (_, i) {
        final d = diseases[i];
        final isSelected = selected == d.name && d.available;
        return _DiseaseTile(
          name: d.name,
          available: d.available,
          selected: isSelected,
          onTap: d.available ? () => onSelect(d.name) : null,
        );
      },
    );
  }
}

class _DiseaseTile extends StatelessWidget {
  const _DiseaseTile({
    required this.name,
    required this.available,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final bool available;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? AppColors.primaryDeep
        : available
            ? AppColors.surface
            : AppColors.disabledBg;
    final textColor = selected
        ? AppColors.textOnPrimary
        : available
            ? AppColors.textPrimary
            : AppColors.disabledText;

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? AppColors.primaryDeep : AppColors.cardBorder,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    size: 18,
                    color: textColor,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (!available)
                const Padding(
                  padding: EdgeInsets.only(top: 2, left: 24),
                  child: Text(
                    '준비 중',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.disabledText,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

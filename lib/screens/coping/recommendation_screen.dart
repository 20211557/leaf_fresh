import 'package:flutter/material.dart';

import '../../models/coping_models.dart';
import '../../theme/app_colors.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({
    super.key,
    required this.result,
    required this.onBack,
    required this.onRetake,
    required this.onGoHome,
  });

  final CopingResult result;
  final VoidCallback onBack;
  final VoidCallback onRetake;
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Header(onBack: onBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            children: _buildBody(),
          ),
        ),
        SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRetake,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.cardBorder),
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: const Text('체크리스트 다시 작성'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onGoHome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3FA862),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(54),
                  ),
                  child: const Text('홈으로'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildBody() {
    switch (result.kind) {
      case CopingResultKind.noDrugNeeded:
        return [
          const _NoDrugHero(
            title: '지금은 약제 살포가 필요 없어요',
            subtitle: '수확까지 14일 이내로 안전사용기준에 맞는 약제가 없습니다.',
          ),
          const SizedBox(height: 16),
          _NoDrugReasons(
            title: '왜 약제를 추천하지 않나요?',
            reasons: result.noDrugReasons,
          ),
          const SizedBox(height: 12),
          if (result.nonDrugs.isNotEmpty) ...[
            _NonDrugSection(methods: result.nonDrugs),
            const SizedBox(height: 12),
          ],
          if (result.nextStagePrep.isNotEmpty) ...[
            _NextStageCard(items: result.nextStagePrep),
            const SizedBox(height: 12),
          ],
          const _DisclaimerCard(),
          const SizedBox(height: 16),
        ];

      case CopingResultKind.noDrugHarvest:
        return [
          const _NoDrugHero(
            title: '지금은 약제 살포가 필요 없어요',
            subtitle: '등숙기에는 방제 효과가 거의 없어요. 수확 후 관리에 집중해 주세요.',
          ),
          const SizedBox(height: 16),
          _PostHarvestSection(items: result.postHarvestActions),
          const SizedBox(height: 12),
          const _DisclaimerCard(),
          const SizedBox(height: 16),
        ];

      case CopingResultKind.sprayBlocked:
        return [
          const _SprayBlockedHero(),
          const SizedBox(height: 16),
          _NoDrugReasons(
            title: '왜 지금은 살포할 수 없나요?',
            reasons: result.reasons,
            accent: const Color(0xFF6B6F66),
          ),
          const SizedBox(height: 12),
          if (result.nonDrugs.isNotEmpty) ...[
            _NonDrugSection(methods: result.nonDrugs),
            const SizedBox(height: 12),
          ],
          const _DisclaimerCard(),
          const SizedBox(height: 16),
        ];

      case CopingResultKind.granuleOnly:
        return [
          _GranuleOnlyHero(drug: result.primaryDrug!),
          const SizedBox(height: 16),
          _WhyCard(reasons: result.reasons),
          const SizedBox(height: 12),
          if (result.nonDrugs.isNotEmpty) ...[
            _NonDrugSection(methods: result.nonDrugs),
            const SizedBox(height: 12),
          ],
          const _DisclaimerCard(),
          const SizedBox(height: 16),
        ];

      case CopingResultKind.ecoOnly:
        return [
          const _EcoBanner(),
          const SizedBox(height: 12),
          _DrugHero(
            drug: result.primaryDrug!,
            kind: result.kind,
            showWarning: false,
          ),
          const SizedBox(height: 16),
          _WhyCard(reasons: result.reasons),
          const SizedBox(height: 12),
          if (result.drugs.length > 1) ...[
            _AlternativesSection(drugs: result.drugs.sublist(1)),
            const SizedBox(height: 12),
          ],
          if (result.nonDrugs.isNotEmpty) ...[
            _NonDrugSection(methods: result.nonDrugs),
            const SizedBox(height: 12),
          ],
          if (result.notice != null) ...[
            _NoticeCard(text: result.notice!),
            const SizedBox(height: 12),
          ],
          const _DisclaimerCard(),
          const SizedBox(height: 16),
        ];

      case CopingResultKind.ecoInsufficient:
        return [
          const _EcoInsufficientHero(),
          const SizedBox(height: 12),
          ...List.generate(result.drugs.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PriorityDrugCard(rank: i + 1, drug: result.drugs[i]),
            );
          }),
          _WhyCard(reasons: result.reasons),
          const SizedBox(height: 12),
          if (result.nonDrugs.isNotEmpty) ...[
            _NonDrugSection(methods: result.nonDrugs),
            const SizedBox(height: 12),
          ],
          if (result.bottomNote != null) ...[
            _EcoComebackBanner(text: result.bottomNote!),
            const SizedBox(height: 12),
          ],
          const _DisclaimerCard(),
          const SizedBox(height: 16),
        ];

      case CopingResultKind.warningDrug:
        return [
          _DrugHero(
            drug: result.primaryDrug!,
            kind: result.kind,
            showWarning: result.primaryDrug!.safetyDaysBeforeHarvest == 14,
          ),
          const SizedBox(height: 16),
          _WhyCard(reasons: result.reasons),
          const SizedBox(height: 12),
          if (result.drugs.length > 1) ...[
            _AlternativesSection(drugs: result.drugs.sublist(1)),
            const SizedBox(height: 12),
          ],
          if (result.nonDrugs.isNotEmpty) ...[
            _NonDrugSection(methods: result.nonDrugs),
            const SizedBox(height: 12),
          ],
          if (result.notice != null) ...[
            _NoticeCard(text: result.notice!),
            const SizedBox(height: 12),
          ],
          const _DisclaimerCard(),
          const SizedBox(height: 16),
        ];

      case CopingResultKind.multipleDrugs:
        return [
          _DrugHero(
            drug: result.primaryDrug!,
            kind: result.kind,
            showWarning: false,
          ),
          const SizedBox(height: 16),
          _WhyCard(reasons: result.reasons),
          const SizedBox(height: 12),
          if (result.drugs.length > 1) ...[
            _AlternativesSection(drugs: result.drugs.sublist(1)),
            const SizedBox(height: 12),
          ],
          if (result.nonDrugs.isNotEmpty) ...[
            _NonDrugSection(methods: result.nonDrugs),
            const SizedBox(height: 12),
          ],
          if (result.notice != null) ...[
            _NoticeCard(text: result.notice!),
            const SizedBox(height: 12),
          ],
          const _DisclaimerCard(),
          const SizedBox(height: 16),
        ];
    }
  }
}

// -----------------------------------------------------------------------------
// 상단 헤더 / 친환경 모드 배너
// -----------------------------------------------------------------------------

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
            '맞춤 추천 결과',
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

class _EcoBanner extends StatelessWidget {
  const _EcoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F0E1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.eco, color: Color(0xFF3FA862), size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '친환경 인증 모드',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2E7D45),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '화학 살균제는 자동으로 제외하고 등록된 친환경 약제만 표시합니다.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF3D5C46),
                    height: 1.4,
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

// -----------------------------------------------------------------------------
// 히어로 카드 변형
// -----------------------------------------------------------------------------

class _NoDrugHero extends StatelessWidget {
  const _NoDrugHero({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD8EBDC),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF3FA862),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F4A2C),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF3D5C46),
                    height: 1.5,
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

class _EcoInsufficientHero extends StatelessWidget {
  const _EcoInsufficientHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCDDD7),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFE66457),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '지금은 생물농약만으로는 부족한 상황이에요',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7A2E26),
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '발병주율 20%를 넘었어요. 화학 약제 사용을 권장해요.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7A2E26),
                    height: 1.5,
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

class _SprayBlockedHero extends StatelessWidget {
  const _SprayBlockedHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEEFEA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD9D9CF)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: Color(0xFF6B6F66), size: 26),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '지금은 약제 살포가 어려워요',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '강수 또는 강풍으로 경엽 살포 조건이 충족되지 않아요. 기상이 회복되면 바로 살포할 수 있도록 준비해 두세요.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.55,
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

class _GranuleOnlyHero extends StatelessWidget {
  const _GranuleOnlyHero({required this.drug});
  final Drug drug;

  static const _bg = Color(0xFFFDF6E0);
  static const _accent = Color(0xFFE0A93C);
  static const _accentDeep = Color(0xFF7A6322);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: _accent, size: 24),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '경엽 살포가 어려운 상황이에요',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _accentDeep,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '강수 또는 강풍 조건에서도 사용할 수 있는 입제를 추천해요.',
                      style: TextStyle(
                        fontSize: 13,
                        color: _accentDeep,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 1,
            color: _accent.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 14),
          const Text(
            '추천 약제',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            drug.brand,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            drug.ingredient,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _accent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              drug.formulation.label.replaceAll('수화제', '제'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _Stat(label: '방법', value: drug.dilution)),
              Expanded(child: _Stat(label: '안전기준', value: drug.safetyTimeLabel)),
              Expanded(child: _Stat(label: '횟수', value: drug.safetyCountLabel)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFBEDC2),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.wb_sunny_outlined, color: _accent, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '기상 회복 후 경엽제 추가 가능해요',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _accentDeep,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '아미스타탑 등 경엽제를 병행하면 효과가 더 높아요.',
                        style: TextStyle(
                          fontSize: 12,
                          color: _accentDeep,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: '구매처 찾기',
                  primary: false,
                  accent: _accent,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  label: '상세 정보',
                  primary: true,
                  accent: _accent,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DrugHero extends StatelessWidget {
  const _DrugHero({
    required this.drug,
    required this.kind,
    required this.showWarning,
  });

  final Drug drug;
  final CopingResultKind kind;
  final bool showWarning;

  Color get _bg {
    if (kind == CopingResultKind.ecoOnly) return const Color(0xFFE3F0E1);
    if (showWarning) return const Color(0xFFFCDDD7);
    return const Color(0xFFE6EEF6);
  }

  Color get _accent {
    if (kind == CopingResultKind.ecoOnly) return const Color(0xFF3FA862);
    if (showWarning) return const Color(0xFFE66457);
    return const Color(0xFF3C7FB6);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BottleTag(label: drug.formulation.label, accent: _accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (kind == CopingResultKind.ecoOnly) const _EcoBadge(),
                    Text(
                      '1순위 추천 방제 방법 · ${drug.maker}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _accent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      drug.brand,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      drug.ingredient,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _StatsRow(drug: drug),
          if (showWarning) ...[
            const SizedBox(height: 12),
            _SafetyWarning(accent: _accent),
          ],
          if (kind == CopingResultKind.ecoOnly) ...[
            const SizedBox(height: 8),
            const _EcoNoticeLine(),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: '구매처 찾기',
                  primary: kind != CopingResultKind.warningDrug,
                  accent: _accent,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  label: '상세 정보',
                  primary: kind == CopingResultKind.warningDrug,
                  accent: _accent,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottleTag extends StatelessWidget {
  const _BottleTag({required this.label, required this.accent});
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 92,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 20,
            height: 8,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 6, right: 6),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EcoBadge extends StatelessWidget {
  const _EcoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF3FA862),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        '✓ 친환경',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.drug});
  final Drug drug;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(child: _Stat(label: '희석', value: drug.dilution)),
          Expanded(child: _Stat(label: '수확', value: drug.safetyTimeLabel)),
          Expanded(child: _Stat(label: '횟수', value: drug.safetyCountLabel)),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _SafetyWarning extends StatelessWidget {
  const _SafetyWarning({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: accent, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '수확 14일 전까지만 사용',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '이 시기는 안전기준이 짧아요.\n수확일을 꼭 확인한 후 살포하세요.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: AppColors.textPrimary,
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

class _EcoNoticeLine extends StatelessWidget {
  const _EcoNoticeLine();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary),
        SizedBox(width: 4),
        Expanded(
          child: Text(
            '효과 변동성이 있어 정기 예찰과 병행 필수',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.primary,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool primary;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = primary ? accent : Colors.white;
    final fg = primary ? Colors.white : AppColors.textPrimary;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: primary ? null : Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 친환경 부족 — 우선순위 약제 카드 (히어로 아래에 줄세움)
// -----------------------------------------------------------------------------

class _PriorityDrugCard extends StatelessWidget {
  const _PriorityDrugCard({required this.rank, required this.drug});
  final int rank;
  final Drug drug;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BottleTag(
                label: drug.formulation.label,
                accent: const Color(0xFF3C7FB6),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$rank순위 · ${drug.maker.replaceAll('(주)', '').replaceAll(' 코리아', '')}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF3C7FB6),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      drug.brand,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      drug.ingredient,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _Stat(label: '희석', value: drug.dilution)),
              Expanded(
                  child: _Stat(label: '안전기준', value: drug.safetyTimeLabel)),
              Expanded(child: _Stat(label: '횟수', value: drug.safetyCountLabel)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: '구매처 찾기',
                  primary: false,
                  accent: const Color(0xFF3C7FB6),
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  label: '상세 정보',
                  primary: true,
                  accent: const Color(0xFF3C7FB6),
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 본문 섹션
// -----------------------------------------------------------------------------

class _WhyCard extends StatelessWidget {
  const _WhyCard({required this.reasons});
  final List<String> reasons;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.wb_sunny_outlined,
                  color: Color(0xFF3FA862), size: 18),
              SizedBox(width: 6),
              Text(
                '왜 이 방법인가요?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...reasons.map(_ReasonRow.new),
        ],
      ),
    );
  }
}

class _ReasonRow extends StatelessWidget {
  const _ReasonRow(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle, size: 18, color: Color(0xFF3FA862)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.textPrimary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoDrugReasons extends StatelessWidget {
  const _NoDrugReasons({
    required this.title,
    required this.reasons,
    this.accent = const Color(0xFFE0A93C),
  });
  final String title;
  final List<String> reasons;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: accent, size: 20),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(reasons.length, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      reasons[i],
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AlternativesSection extends StatelessWidget {
  const _AlternativesSection({required this.drugs});
  final List<Drug> drugs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '다른 약제 후보',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              '${drugs.length}개',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...List.generate(drugs.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _AlternativeCard(rank: i + 2, drug: drugs[i]),
          );
        }),
      ],
    );
  }
}

class _AlternativeCard extends StatelessWidget {
  const _AlternativeCard({required this.rank, required this.drug});
  final int rank;
  final Drug drug;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4D8C8),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  drug.formulation == DrugFormulation.granule ? '입제' : '액상수화',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7A4A2A),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$rank순위',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          drug.maker
                              .replaceAll('(주)', '')
                              .replaceAll(' 코리아', ''),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      drug.brand,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      drug.ingredient,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _MiniPill(
                  label:
                      '수확 ${drug.safetyTimeLabel.replaceAll('수확 ', '').replaceAll(' ', '')}'),
              _MiniPill(label: '횟수 ${drug.safetyCountLabel}'),
              _MiniPill(label: '희석 ${drug.dilution}'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SmallActionButton(
                  label: '구매처 찾기',
                  primary: true,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SmallActionButton(
                  label: '상세 정보',
                  primary: false,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDECE5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  const _SmallActionButton({
    required this.label,
    required this.primary,
    required this.onTap,
  });
  final String label;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primary ? const Color(0xFF1F2A24) : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: primary ? null : Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: primary ? Colors.white : AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _NonDrugSection extends StatelessWidget {
  const _NonDrugSection({required this.methods});
  final List<NonDrugMethod> methods;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE6EFE3),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.eco, color: Color(0xFF3FA862), size: 18),
              SizedBox(width: 6),
              Text(
                '함께 적용할 비약제 방법',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...methods.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _MethodRow(method: m, accentColor: const Color(0xFF3FA862)),
              )),
        ],
      ),
    );
  }
}

class _MethodRow extends StatelessWidget {
  const _MethodRow({required this.method, required this.accentColor});
  final NonDrugMethod method;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_iconFor(method.id), color: accentColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  method.description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String id) {
    switch (id) {
      case 'ventilation':
        return Icons.air;
      case 'awd':
        return Icons.water_drop_outlined;
      case 'mid_drain':
        return Icons.water;
      case 'scout':
        return Icons.visibility_outlined;
      case 'fertilizer':
        return Icons.wb_sunny_outlined;
      case 'sclerotia':
        return Icons.filter_alt_outlined;
      case 'isolate':
        return Icons.warning_amber_outlined;
      case 'straw_dispose':
        return Icons.eco;
      case 'post_record':
        return Icons.description_outlined;
      case 'post_next_year':
        return Icons.calendar_today_outlined;
      default:
        return Icons.eco;
    }
  }
}

class _PostHarvestSection extends StatelessWidget {
  const _PostHarvestSection({required this.items});
  final List<NonDrugMethod> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.description_outlined,
                  color: Color(0xFF3C7FB6), size: 20),
              SizedBox(width: 6),
              Text(
                '수확 후 이렇게 해주세요',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PostHarvestRow(item: m),
              )),
        ],
      ),
    );
  }
}

class _PostHarvestRow extends StatelessWidget {
  const _PostHarvestRow({required this.item});
  final NonDrugMethod item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EBF9),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(_iconFor(item.id),
              color: const Color(0xFF3C7FB6), size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _iconFor(String id) {
    switch (id) {
      case 'post_record':
        return Icons.description_outlined;
      case 'straw_dispose':
        return Icons.eco;
      case 'post_next_year':
        return Icons.calendar_today_outlined;
      default:
        return Icons.task_alt;
    }
  }
}

class _NextStageCard extends StatelessWidget {
  const _NextStageCard({required this.items});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE6EFE3),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.calendar_today_outlined,
                  color: Color(0xFF3FA862), size: 18),
              SizedBox(width: 6),
              Text(
                '다음 시기 방제 준비',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((t) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.check_circle,
                          size: 16, color: Color(0xFF3FA862)),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        t,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textPrimary,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDF6E0),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFE0A93C), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '비고',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7A6322),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5A4A1F),
                    height: 1.5,
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

class _EcoComebackBanner extends StatelessWidget {
  const _EcoComebackBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE6EFE3),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.eco, color: Color(0xFF3FA862), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF2E5A36),
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: const Text(
        '살포 전 제품 라벨과 농약안전정보시스템의 최신 안전사용기준을 반드시 확인하세요.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }
}

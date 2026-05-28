import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/growth_stage.dart';
import '../../models/user_settings.dart';
import '../../theme/app_colors.dart';
import '../home/home_screen.dart';

class SetupCompleteScreen extends StatelessWidget {
  const SetupCompleteScreen({super.key, required this.settings});

  final UserSettings settings;

  @override
  Widget build(BuildContext context) {
    final activeIndex = GrowthStageCalculator.activeIndex(settings.transplantDate);
    final stages = GrowthStageCalculator.riceStages;
    final (rangeStart, rangeEnd) =
        GrowthStageCalculator.rangeOf(settings.transplantDate, activeIndex);
    final dateFormat = DateFormat('y년 M월 d일', 'ko_KR');

    return Scaffold(
      backgroundColor: AppColors.completeBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const _CheckmarkBadge(),
              const SizedBox(height: 14),
              const Text(
                '설  정   완  료',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFD9DFD3),
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '이제 예보를 받아볼 준비가 됐어요',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 28),
              _InfoCard(
                icon: Icons.location_on_outlined,
                label: '지역',
                value: settings.region,
              ),
              const SizedBox(height: 10),
              _InfoCard(
                icon: Icons.eco_outlined,
                label: '작물 · 병해충',
                value: '${settings.crop} · ${settings.disease}',
                emoji: '🌾',
              ),
              const SizedBox(height: 10),
              _InfoCard(
                icon: Icons.calendar_today_outlined,
                label: '이앙일',
                value: dateFormat.format(settings.transplantDate),
              ),
              const SizedBox(height: 10),
              _GrowthCard(
                stages: stages,
                activeIndex: activeIndex,
                rangeStart: rangeStart,
                rangeEnd: rangeEnd,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.textPrimary,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  },
                  child: const Text('시작하기'),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '설정은 언제든 다시 변경할 수 있어요',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFFD9DFD3),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckmarkBadge extends StatelessWidget {
  const _CheckmarkBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.check_rounded, size: 48, color: Colors.white),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.emoji,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: emoji != null
                ? Text(emoji!, style: const TextStyle(fontSize: 22))
                : Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFD9DFD3),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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

class _GrowthCard extends StatelessWidget {
  const _GrowthCard({
    required this.stages,
    required this.activeIndex,
    required this.rangeStart,
    required this.rangeEnd,
  });

  final List<GrowthStage> stages;
  final int activeIndex;
  final DateTime rangeStart;
  final DateTime rangeEnd;

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('M/d');
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '생육 단계',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                '${format.format(rangeStart)} ~ ${format.format(rangeEnd)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFD9DFD3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth;
            final segments = stages.length - 1;
            return SizedBox(
              height: 44,
              child: Stack(
                children: [
                  Positioned(
                    left: 8,
                    right: 8,
                    top: 11,
                    child: Container(
                      height: 2,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  ...List.generate(stages.length, (i) {
                    final ratio = segments == 0 ? 0.0 : i / segments;
                    final x = ratio * (width - 24);
                    final isActive = i == activeIndex;
                    return Positioned(
                      left: x,
                      top: 0,
                      child: Column(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.45),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 56,
                            child: Center(
                              child: Text(
                                stages[i].name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isActive
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                  color: isActive
                                      ? Colors.white
                                      : const Color(0xFFD9DFD3),
                                ),
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
          }),
        ],
      ),
    );
  }
}

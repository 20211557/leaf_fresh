import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class ScoutTab extends StatelessWidget {
  const ScoutTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search,
              size: 44,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            '예찰 결과',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '카메라로 잎을 촬영해 병해충을 진단하는\n예찰 기능이 준비 중입니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

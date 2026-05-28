import 'package:flutter/material.dart';

import '../../../models/forecast.dart';
import '../../../theme/app_colors.dart';

class ReportCard extends StatelessWidget {
  const ReportCard({super.key, required this.index, required this.card});

  final int index;
  final ForecastCard card;

  @override
  Widget build(BuildContext context) {
    final type = _ReportCardType.fromCard(card);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF2F2F2F),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              index.toString().padLeft(2, '0'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: type.bg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        type.label,
                        style: TextStyle(
                          color: type.fg,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (card.subtitle != null && card.subtitle!.isNotEmpty)
                      Flexible(
                        child: Text(
                          card.subtitle!,
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
                ),
                const SizedBox(height: 10),
                Text(
                  card.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
                ),
                if (card.message.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    card.message,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCardType {
  const _ReportCardType({
    required this.label,
    required this.fg,
    required this.bg,
  });

  final String label;
  final Color fg;
  final Color bg;

  factory _ReportCardType.fromCard(ForecastCard card) {
    final type = card.type.toLowerCase();
    if (type == 'lag') {
      return const _ReportCardType(
        label: 'LAG',
        fg: Color(0xFF6F4FB0),
        bg: Color(0xFFEDE6F8),
      );
    }
    if (type == 'ctm') {
      return const _ReportCardType(
        label: 'CTM',
        fg: Color(0xFF3C7FB6),
        bg: Color(0xFFDDEBF7),
      );
    }
    return const _ReportCardType(
      label: '기상 요인',
      fg: Color(0xFF5A5A5A),
      bg: Color(0xFFEDECE5),
    );
  }
}

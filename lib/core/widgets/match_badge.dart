import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// "92% match" pill. Green when 70%+, orange otherwise.
class MatchBadge extends StatelessWidget {
  final int percent;
  const MatchBadge({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    final good = percent >= 70;
    final fg = good ? AppColors.matchGreen : AppColors.orangeDeep;
    final bg = good ? AppColors.matchGreenSoft : AppColors.orangeSoft;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 14, color: fg),
          const SizedBox(width: 4),
          Text('$percent% match',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;
  const SectionHeader({super.key, required this.title, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: const Text('View all',
                  style: TextStyle(
                      color: AppColors.orange,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ),
        ],
      ),
    );
  }
}

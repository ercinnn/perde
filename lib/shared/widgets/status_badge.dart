import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum BadgeTone { orange, red, green, blue, grey }

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, this.tone = BadgeTone.orange});

  final String label;
  final BadgeTone tone;

  Color get _color {
    switch (tone) {
      case BadgeTone.orange:
        return AppColors.primary;
      case BadgeTone.red:
        return AppColors.danger;
      case BadgeTone.green:
        return AppColors.success;
      case BadgeTone.blue:
        return AppColors.info;
      case BadgeTone.grey:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

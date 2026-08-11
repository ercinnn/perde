import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.child,
    this.width,
  });

  final String label;
  final Widget child;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
    if (width == null) return content;
    return SizedBox(width: width, child: content);
  }
}

/// A responsive row that wraps its children onto new lines on narrow screens.
class FieldRow extends StatelessWidget {
  const FieldRow({super.key, required this.children, this.spacing = 16});

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: children,
    );
  }
}

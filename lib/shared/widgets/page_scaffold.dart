import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
    this.icon,
  });

  final String title;
  final Widget child;
  final List<Widget> actions;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Text(
                      icon == null ? title : '$icon $title',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (actions.isNotEmpty) ...[
                Wrap(spacing: 10, runSpacing: 8, children: actions),
                const SizedBox(width: 20),
              ],
              const _AccountBar(),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: child,
          ),
        ),
      ],
    );
  }
}

class _AccountBar extends StatelessWidget {
  const _AccountBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Yıldız Perde Dekorasyon',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        const SizedBox(width: 14),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Çıkış (demo)')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text('Çıkış'),
        ),
      ],
    );
  }
}

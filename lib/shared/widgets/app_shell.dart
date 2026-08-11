import 'package:flutter/material.dart';
import 'sidebar.dart';
import '../../core/theme/app_colors.dart';

const _mobileBreakpoint = 900.0;

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.currentPath, required this.child});

  final String currentPath;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= _mobileBreakpoint;

    if (isWide) {
      return Scaffold(
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Sidebar(currentPath: currentPath),
            Expanded(
              child: ColoredBox(
                color: AppColors.background,
                child: child,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.sidebar,
        foregroundColor: Colors.white,
        title: const Text('Yıldız Perde Dekorasyon'),
      ),
      drawer: Drawer(
        child: Builder(
          builder: (ctx) => Sidebar(
            currentPath: currentPath,
            onNavigate: () => Navigator.of(ctx).pop(),
          ),
        ),
      ),
      body: child,
    );
  }
}

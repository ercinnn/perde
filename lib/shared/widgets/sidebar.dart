import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';

class NavItem {
  const NavItem(this.icon, this.label, this.route, {this.children = const []});
  final String icon;
  final String label;
  final String? route;
  final List<NavItem> children;
}

const _businessTools = NavItem('✨', 'İşletme Araçları', null, children: [
  NavItem('💱', 'Tedarikçi Fiyat Karşılaştırma', Routes.priceComparison),
  NavItem('📊', 'Müşteri Kâr Analizi', Routes.customerProfit),
  NavItem('💳', 'Borç Ödeme Takibi', Routes.debtTracking),
  NavItem('📒', 'Cari Hesap', Routes.finance),
  NavItem('🗓️', 'Haftalık Plan', Routes.weeklyPlan),
  NavItem('🏷️', 'Ekstra Fiyat Listesi', Routes.extraPrices),
  NavItem('🗓️', 'Teslimat Tarihi Hesapla', Routes.deliveryCalc),
  NavItem('📐', 'Hesaplama Notu', Routes.calcNote),
]);

const sidebarItems = [
  NavItem('🏠', 'Kontrol Paneli', Routes.dashboard),
  NavItem('📋', 'Sipariş Formu', Routes.orderForm),
  NavItem('👤', 'Müşteri Listesi', Routes.customers),
  _businessTools,
  NavItem('📦', 'Stok & Tedarik', Routes.stock),
  NavItem('⚙️', 'Ayarlar', Routes.settings),
  NavItem('🔑', 'Lisans', Routes.license),
];

class Sidebar extends StatefulWidget {
  const Sidebar({super.key, required this.currentPath, this.onNavigate});

  final String currentPath;
  final VoidCallback? onNavigate;

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool _toolsExpanded = false;

  bool _pathMatches(String route) =>
      widget.currentPath == route ||
      (route != '/' && widget.currentPath.startsWith(route));

  @override
  void initState() {
    super.initState();
    _toolsExpanded =
        _businessTools.children.any((c) => _pathMatches(c.route!));
  }

  @override
  void didUpdateWidget(covariant Sidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_businessTools.children.any((c) => _pathMatches(c.route!))) {
      _toolsExpanded = true;
    }
  }

  void _go(BuildContext context, String route) {
    context.go(route);
    widget.onNavigate?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: AppColors.sidebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.sidebarBorder)),
            ),
            child: const Text(
              'Yıldız Perde Dekorasyon',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (final item in sidebarItems) _buildItem(context, item),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, NavItem item) {
    if (item.children.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _toolsExpanded = !_toolsExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Text(item.icon, style: const TextStyle(fontSize: 15)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.label,
                      style: const TextStyle(
                        color: AppColors.sidebarText,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                  Icon(
                    _toolsExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.sidebarText,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          if (_toolsExpanded)
            for (final child in item.children) _buildLeaf(context, child, sub: true),
        ],
      );
    }
    return _buildLeaf(context, item);
  }

  Widget _buildLeaf(BuildContext context, NavItem item, {bool sub = false}) {
    final active = _pathMatches(item.route!);
    return InkWell(
      onTap: () => _go(context, item.route!),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        padding: EdgeInsets.symmetric(
          horizontal: sub ? 18 : 12,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: active ? AppColors.sidebarActive : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: active
              ? const Border(left: BorderSide(color: AppColors.primary, width: 3))
              : null,
        ),
        child: Row(
          children: [
            Text(item.icon, style: TextStyle(fontSize: sub ? 13 : 15)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  color: active ? Colors.white : AppColors.sidebarText,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  fontSize: sub ? 12.5 : 13.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

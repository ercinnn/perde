import 'package:flutter/material.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/segmented_tabs.dart';
import 'widgets/stock_entry_tab.dart';
import 'widgets/stock_report_tab.dart';
import 'widgets/stock_requests_tab.dart';
import 'widgets/stock_status_tab.dart';
import 'widgets/suppliers_tab.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  int _tab = 0;

  static const _labels = [
    'Stok Durumu',
    'Stok Girişi',
    'Tedarikçiler',
    'Sipariş Talepleri',
    'Stok Raporu',
  ];

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Stok & Tedarik',
      icon: '📦',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedTabs(
            labels: _labels,
            selectedIndex: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: 20),
          IndexedStack(
            index: _tab,
            children: const [
              StockStatusTab(),
              StockEntryTab(),
              SuppliersTab(),
              StockRequestsTab(),
              StockReportTab(),
            ],
          ),
        ],
      ),
    );
  }
}

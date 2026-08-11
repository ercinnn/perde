import 'package:flutter/material.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/segmented_tabs.dart';
import 'widgets/cash_report_tab.dart';
import 'widgets/installments_tab.dart';
import 'widgets/receivables_tab.dart';
import 'widgets/reminders_tab.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  int _tab = 0;

  static const _labels = [
    'Veresiye Takibi',
    'Taksit Sistemi',
    'Ödeme Hatırlatma',
    'Gün Sonu Kasa Raporu',
  ];

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Finans',
      icon: '💰',
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
              ReceivablesTab(),
              InstallmentsTab(),
              RemindersTab(),
              CashReportTab(),
            ],
          ),
        ],
      ),
    );
  }
}

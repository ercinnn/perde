import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/order_models.dart';
import '../../data/providers/orders_provider.dart';
import '../../shared/widgets/labeled_field.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/section_card.dart';
import '../../shared/widgets/stat_card.dart';

const _estimatedCostRatio = 0.6;

class CustomerProfitScreen extends ConsumerStatefulWidget {
  const CustomerProfitScreen({super.key});

  @override
  ConsumerState<CustomerProfitScreen> createState() => _CustomerProfitScreenState();
}

class _CustomerProfitScreenState extends ConsumerState<CustomerProfitScreen> {
  String? _selectedPhone;
  String? _analyzedPhone;

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customersProvider);
    _selectedPhone ??= customers.isNotEmpty ? customers.first.phone : null;
    CustomerSummary? byPhone(String? phone) {
      for (final c in customers) {
        if (c.phone == phone) return c;
      }
      return null;
    }

    final analyzed = byPhone(_analyzedPhone);
    final sales = analyzed?.totalAmount ?? 0;
    final cost = sales * _estimatedCostRatio;
    final profit = sales - cost;
    final margin = sales == 0 ? 0 : (profit / sales * 100);

    return PageScaffold(
      title: 'Müşteri Kâr Analizi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              LabeledField(
                label: 'Müşteri Seç',
                width: 260,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedPhone,
                  items: [
                    for (final c in customers)
                      DropdownMenuItem(value: c.phone, child: Text(c.name)),
                  ],
                  onChanged: (v) => setState(() => _selectedPhone = v),
                ),
              ),
              const SizedBox(width: 16),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: () => setState(() => _analyzedPhone = _selectedPhone),
                  child: const Text('ANALİZ ET'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              StatCard(value: Formatters.currency(sales), label: 'TOPLAM SATIŞ', color: const Color(0xFFC9A227)),
              StatCard(value: Formatters.currency(cost), label: 'TOPLAM MALİYET', color: AppColors.danger),
              StatCard(value: Formatters.currency(profit), label: 'TOPLAM KÂR', color: AppColors.info),
              StatCard(value: '%${margin.toStringAsFixed(0)}', label: 'KÂR ORANI', color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 20),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ürün Detayları', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                if (analyzed == null)
                  const Text('Bir müşteri seçip "ANALİZ ET" butonuna basın.',
                      style: TextStyle(color: AppColors.textMuted))
                else
                  for (final o in analyzed.orders)
                    for (final item in o.items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '${item.productType.label} (${item.room.label}) — ${Formatters.currency(item.total)}',
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

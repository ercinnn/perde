import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/enums.dart';
import '../../data/models/order_models.dart';
import '../../data/providers/orders_provider.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/section_card.dart';
import '../../shared/widgets/status_badge.dart';
import 'widgets/customer_detail_dialog.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customersProvider);
    final query = _searchCtrl.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? customers
        : customers
            .where((c) =>
                c.name.toLowerCase().contains(query) ||
                c.phone.contains(query) ||
                c.address.toLowerCase().contains(query))
            .toList();

    return PageScaffold(
      title: 'Müşteri Listesi',
      icon: '👤',
      actions: [
        OutlinedButton(
          onPressed: () => setState(() {}),
          child: const Text('↻ Yenile'),
        ),
        ElevatedButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tüm sipariş PDF\'leri yedekleniyor (demo)')),
          ),
          child: const Text('📥 Tüm Sipariş PDF\'lerini Yedekle'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Müşteri Listesi  ',
                  style: Theme.of(context).textTheme.titleMedium),
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.info,
                child: Text('${filtered.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchCtrl,
            decoration: const InputDecoration(hintText: 'İsim, telefon veya adres ile ara...'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          SectionCard(
            padding: EdgeInsets.zero,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.background),
                columns: const [
                  DataColumn(label: Text('AD SOYAD')),
                  DataColumn(label: Text('TELEFON')),
                  DataColumn(label: Text('SİPARİŞ TARİHİ')),
                  DataColumn(label: Text('TESLİMAT TARİHİ')),
                  DataColumn(label: Text('SİPARİŞ DURUMU')),
                  DataColumn(label: Text('ADRES')),
                ],
                rows: [
                  for (final c in filtered)
                    DataRow(
                      onSelectChanged: (_) => showCustomerDetailDialog(context, c),
                      cells: [
                        DataCell(Text(c.name)),
                        DataCell(Text(c.phone)),
                        DataCell(Text(Formatters.date(c.latestOrder.orderDate))),
                        DataCell(Text(Formatters.date(c.latestOrder.deliveryDate))),
                        DataCell(_StatusDropdown(order: c.latestOrder)),
                        DataCell(SizedBox(
                          width: 260,
                          child: Text(c.address, overflow: TextOverflow.ellipsis),
                        )),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDropdown extends ConsumerWidget {
  const _StatusDropdown({required this.order});
  final Order order;

  BadgeTone _tone(OrderStatus s) {
    switch (s) {
      case OrderStatus.teslimEdildi:
        return BadgeTone.green;
      case OrderStatus.iptal:
        return BadgeTone.red;
      case OrderStatus.hazirlaniyor:
        return BadgeTone.blue;
      case OrderStatus.bekliyor:
        return BadgeTone.orange;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<OrderStatus>(
      onSelected: (s) => ref.read(ordersProvider.notifier).setStatus(order.id, s),
      itemBuilder: (context) => [
        for (final s in OrderStatus.values)
          PopupMenuItem(value: s, child: Text(s.label)),
      ],
      child: StatusBadge(label: order.status.label, tone: _tone(order.status)),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/stock_models.dart';
import '../../../data/providers/stock_provider.dart';
import '../../../shared/widgets/labeled_field.dart';
import '../../../shared/widgets/section_card.dart';

class StockRequestsTab extends ConsumerStatefulWidget {
  const StockRequestsTab({super.key});

  @override
  ConsumerState<StockRequestsTab> createState() => _StockRequestsTabState();
}

class _StockRequestsTabState extends ConsumerState<StockRequestsTab> {
  final _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final requests = ref.watch(stockRequestsProvider);
    final suppliers = ref.watch(suppliersProvider);
    final query = _searchCtrl.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? requests
        : requests
            .where((r) =>
                r.productName.toLowerCase().contains(query) ||
                r.supplierName.toLowerCase().contains(query))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(hintText: 'Ürün / tedarikçi ara...'),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => _showRequestForm(context, suppliers),
              child: const Text('+ Yeni Talep'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          const SectionCard(child: Text('Henüz sipariş talebi yok.'))
        else
          for (final r in filtered)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SectionCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${r.productName} — ${r.supplierName}',
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text(
                            '${Formatters.number(r.quantity)} ${r.unit} · Teslim: ${Formatters.date(r.deliveryDate)}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () =>
                          ref.read(stockRequestsProvider.notifier).removeRequest(r.id),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  void _showRequestForm(BuildContext context, List<Supplier> suppliers) {
    String? supplierName;
    final productCtrl = TextEditingController();
    final quantityCtrl = TextEditingController();
    String unit = 'metre';
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Yeni Sipariş Talebi',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  LabeledField(
                    label: 'Tedarikçi',
                    child: DropdownButtonFormField<String>(
                      initialValue: supplierName,
                      hint: const Text('— Seçin —'),
                      items: [
                        for (final s in suppliers)
                          DropdownMenuItem(value: s.name, child: Text(s.name)),
                      ],
                      onChanged: (v) => setState(() => supplierName = v),
                    ),
                  ),
                  const SizedBox(height: 14),
                  LabeledField(label: 'Ürün Adı *', child: TextField(controller: productCtrl)),
                  const SizedBox(height: 14),
                  FieldRow(children: [
                    LabeledField(
                      label: 'Miktar',
                      width: 140,
                      child: TextField(controller: quantityCtrl, keyboardType: TextInputType.number),
                    ),
                    LabeledField(
                      label: 'Birim',
                      width: 140,
                      child: DropdownButtonFormField<String>(
                        initialValue: unit,
                        items: const [
                          DropdownMenuItem(value: 'metre', child: Text('metre')),
                          DropdownMenuItem(value: 'adet', child: Text('adet')),
                          DropdownMenuItem(value: 'top', child: Text('top')),
                        ],
                        onChanged: (v) => setState(() => unit = v!),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  LabeledField(label: 'Notlar', child: TextField(controller: notesCtrl)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('İptal'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (productCtrl.text.trim().isEmpty) return;
                          final notifier = ref.read(stockRequestsProvider.notifier);
                          notifier.addRequest(StockRequest(
                            id: notifier.nextId(),
                            supplierName: supplierName ?? '-',
                            productName: productCtrl.text.trim(),
                            quantity: double.tryParse(quantityCtrl.text) ?? 0,
                            unit: unit,
                            deliveryDate: DateTime.now().add(const Duration(days: 10)),
                            notes: notesCtrl.text.trim(),
                          ));
                          Navigator.of(context).pop();
                        },
                        child: const Text('KAYDET'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

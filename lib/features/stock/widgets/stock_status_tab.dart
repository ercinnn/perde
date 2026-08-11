import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/stock_models.dart';
import '../../../data/providers/stock_provider.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_badge.dart';

class StockStatusTab extends ConsumerStatefulWidget {
  const StockStatusTab({super.key});

  @override
  ConsumerState<StockStatusTab> createState() => _StockStatusTabState();
}

class _StockStatusTabState extends ConsumerState<StockStatusTab> {
  final _searchCtrl = TextEditingController();
  bool _onlyCritical = false;

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(stockProvider);
    final query = _searchCtrl.text.trim().toLowerCase();
    final filtered = items.where((s) {
      if (_onlyCritical && !s.isCritical) return false;
      if (query.isEmpty) return true;
      return s.name.toLowerCase().contains(query) || s.code.toLowerCase().contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(hintText: 'Ürün ara...'),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: _onlyCritical ? Colors.white : AppColors.danger,
                backgroundColor: _onlyCritical ? AppColors.danger : null,
              ),
              onPressed: () => setState(() => _onlyCritical = !_onlyCritical),
              child: const Text('⚠ Sadece Kritik'),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: () => setState(() {}),
              child: const Text('↻ Yenile'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (final item in filtered)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => _showDetail(context, item),
              child: SectionCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${item.name} [${item.code}]',
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(
                            '${Formatters.number(item.quantity)} ${item.unit} · Min: ${Formatters.number(item.minStock)} · ${item.supplierName}',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(
                      label: item.isCritical ? 'Kritik' : 'Normal',
                      tone: item.isCritical ? BadgeTone.red : BadgeTone.green,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showDetail(BuildContext context, StockItem item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Text('Kod: ${item.code}'),
                Text('Marka: ${item.brand}'),
                Text('Kategori: ${item.category}'),
                Text('Miktar: ${Formatters.number(item.quantity)} ${item.unit}'),
                Text('Min Stok: ${Formatters.number(item.minStock)}'),
                Text('Tedarikçi: ${item.supplierName}'),
                Text('Alış Fiyatı: ${Formatters.currency(item.purchasePrice)}'),
                Text('Kritik: ${item.isCritical ? "EVET" : "HAYIR"}'),
                Text('Son Güncelleme: ${item.lastUpdated}'),
                Text('Açıklama: ${item.description.isEmpty ? "-" : item.description}'),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                      onPressed: () {
                        ref.read(stockProvider.notifier).removeItem(item.id);
                        Navigator.of(context).pop();
                      },
                      child: const Text('SİL'),
                    ),
                    OutlinedButton(
                      onPressed: () => _showAdjustDialog(context, item),
                      child: const Text('MİKTAR AYARLA'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('DÜZENLE'),
                    ),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Kapat'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAdjustDialog(BuildContext context, StockItem item) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Miktar Ayarla'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Değişim (ör. 10 veya -5)'),
          keyboardType: const TextInputType.numberWithOptions(signed: true),
        ),
        actions: [
          OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              final delta = double.tryParse(ctrl.text.replaceAll(',', '.')) ?? 0;
              ref.read(stockProvider.notifier).adjustQuantity(item.id, delta);
              Navigator.of(context)..pop()..pop();
            },
            child: const Text('UYGULA'),
          ),
        ],
      ),
    );
  }
}

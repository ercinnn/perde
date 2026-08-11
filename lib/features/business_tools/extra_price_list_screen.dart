import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/enums.dart';
import '../../data/models/planning_models.dart';
import '../../data/providers/planning_provider.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/section_card.dart';

class ExtraPriceListScreen extends ConsumerWidget {
  const ExtraPriceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fees = ref.watch(pileFeesProvider);
    final features = ref.watch(featurePricesProvider);

    return PageScaffold(
      title: 'Ekstra Fiyat Listesi',
      icon: '🏷️',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🧵 Pile / Dikiş Ücretleri',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Text(
                  'Her pile türü için dikiş ücretini girin. Sipariş formunda "Pile Çeşidi" alanına yazınca otomatik eklenir.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                ),
                const SizedBox(height: 16),
                for (final f in fees)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _FeeRow(
                      name: f.name,
                      price: f.price,
                      onDelete: () => ref.read(pileFeesProvider.notifier).removeFee(f.id),
                    ),
                  ),
                const SizedBox(height: 6),
                OutlinedButton(
                  onPressed: () => _addFeeDialog(context, ref),
                  child: const Text('+ Yeni Pile Ekle'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('⚙️ Ürün Özellik Fiyatları',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Text(
                  'Pliseli/Ahşap Jaluzi/Zebra gibi ürünlerde çıkan opsiyonların ek ücretini (indirimse eksi değer) buradan ayarlayın.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                ),
                const SizedBox(height: 16),
                for (final f in features)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _FeatureRow(
                      feature: f,
                      onDelete: () => ref.read(featurePricesProvider.notifier).removeFeature(f.id),
                    ),
                  ),
                const SizedBox(height: 6),
                OutlinedButton(
                  onPressed: () => _addFeatureDialog(context, ref),
                  child: const Text('+ Yeni Özellik Ekle'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addFeeDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Pile Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Ad')),
            const SizedBox(height: 10),
            TextField(
              controller: priceCtrl,
              decoration: const InputDecoration(labelText: 'Fiyat (TL)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              final notifier = ref.read(pileFeesProvider.notifier);
              notifier.addFee(PileFee(
                id: notifier.nextId(),
                name: nameCtrl.text.trim(),
                price: double.tryParse(priceCtrl.text) ?? 0,
              ));
              Navigator.of(context).pop();
            },
            child: const Text('EKLE'),
          ),
        ],
      ),
    );
  }

  void _addFeatureDialog(BuildContext context, WidgetRef ref) {
    ProductType type = ProductType.pliseli;
    final optionCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    FeatureCalcType calcType = FeatureCalcType.sabit;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Yeni Özellik Ekle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<ProductType>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Ürün Tipi'),
                  items: [
                    for (final p in ProductType.values)
                      DropdownMenuItem(value: p, child: Text(p.label)),
                  ],
                  onChanged: (v) => setState(() => type = v!),
                ),
                const SizedBox(height: 10),
                TextField(controller: optionCtrl, decoration: const InputDecoration(labelText: 'Seçenek Adı')),
                const SizedBox(height: 10),
                TextField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: 'Fiyat (TL)'),
                  keyboardType: const TextInputType.numberWithOptions(signed: true),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<FeatureCalcType>(
                  initialValue: calcType,
                  decoration: const InputDecoration(labelText: 'Hesap Tipi'),
                  items: [
                    for (final c in FeatureCalcType.values)
                      DropdownMenuItem(value: c, child: Text(c.label)),
                  ],
                  onChanged: (v) => setState(() => calcType = v!),
                ),
              ],
            ),
          ),
          actions: [
            OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () {
                if (optionCtrl.text.trim().isEmpty) return;
                final notifier = ref.read(featurePricesProvider.notifier);
                notifier.addFeature(ProductFeaturePrice(
                  id: notifier.nextId(),
                  productType: type,
                  optionName: optionCtrl.text.trim(),
                  price: double.tryParse(priceCtrl.text) ?? 0,
                  calcType: calcType,
                ));
                Navigator.of(context).pop();
              },
              child: const Text('EKLE'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  const _FeeRow({required this.name, required this.price, required this.onDelete});
  final String name;
  final double price;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 2, child: Text(name)),
        Expanded(child: Text('${price.toStringAsFixed(0)} TL')),
        TextButton(
          onPressed: onDelete,
          style: TextButton.styleFrom(foregroundColor: AppColors.danger),
          child: const Text('✕ Sil'),
        ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.feature, required this.onDelete});
  final ProductFeaturePrice feature;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(feature.productType.label)),
        Expanded(flex: 2, child: Text(feature.optionName)),
        Expanded(child: Text('${feature.price.toStringAsFixed(0)} TL')),
        Expanded(child: Text(feature.calcType.label)),
        TextButton(
          onPressed: onDelete,
          style: TextButton.styleFrom(foregroundColor: AppColors.danger),
          child: const Text('✕ Sil'),
        ),
      ],
    );
  }
}

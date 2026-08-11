import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/stock_models.dart';
import '../../data/providers/stock_provider.dart';
import '../../shared/widgets/labeled_field.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/section_card.dart';
import '../../shared/widgets/segmented_tabs.dart';

class PriceComparisonScreen extends StatefulWidget {
  const PriceComparisonScreen({super.key});

  @override
  State<PriceComparisonScreen> createState() => _PriceComparisonScreenState();
}

class _PriceComparisonScreenState extends State<PriceComparisonScreen> {
  int _tab = 0;
  static const _labels = ['Fiyat Listesi', 'Fiyat Ekle/Güncelle', 'Karşılaştır'];

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Tedarikçi Fiyat Karşılaştırma',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedTabs(labels: _labels, selectedIndex: _tab, onChanged: (i) => setState(() => _tab = i)),
          const SizedBox(height: 20),
          IndexedStack(
            index: _tab,
            children: const [_PriceListTab(), _PriceAddTab(), _CompareTab()],
          ),
        ],
      ),
    );
  }
}

class _PriceListTab extends ConsumerWidget {
  const _PriceListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliers = ref.watch(suppliersProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton(onPressed: () {}, child: const Text('↻ Yenile')),
        const SizedBox(height: 16),
        for (final s in suppliers)
          for (final p in s.products)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${p.name} — ${s.name}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text('${Formatters.currency(p.price)} / ${p.unit}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class _PriceAddTab extends ConsumerStatefulWidget {
  const _PriceAddTab();

  @override
  ConsumerState<_PriceAddTab> createState() => _PriceAddTabState();
}

class _PriceAddTabState extends ConsumerState<_PriceAddTab> {
  String? _supplierId;
  final _productCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  String _unit = 'metre';

  @override
  Widget build(BuildContext context) {
    final suppliers = ref.watch(suppliersProvider);
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Fiyat Ekle / Güncelle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          FieldRow(children: [
            LabeledField(
              label: 'Tedarikçi',
              width: 220,
              child: DropdownButtonFormField<String>(
                initialValue: _supplierId,
                hint: const Text('— Seçin —'),
                items: [
                  for (final s in suppliers) DropdownMenuItem(value: s.id, child: Text(s.name)),
                ],
                onChanged: (v) => setState(() => _supplierId = v),
              ),
            ),
            LabeledField(label: 'Ürün Adı', width: 220, child: TextField(controller: _productCtrl)),
            LabeledField(
              label: 'Fiyat (TL)',
              width: 150,
              child: TextField(controller: _priceCtrl, keyboardType: TextInputType.number),
            ),
            LabeledField(
              label: 'Birim',
              width: 140,
              child: DropdownButtonFormField<String>(
                initialValue: _unit,
                items: const [
                  DropdownMenuItem(value: 'metre', child: Text('metre')),
                  DropdownMenuItem(value: 'adet', child: Text('adet')),
                ],
                onChanged: (v) => setState(() => _unit = v!),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_supplierId == null || _productCtrl.text.trim().isEmpty) return;
              ref.read(suppliersProvider.notifier).addProductToSupplier(
                    _supplierId!,
                    SupplierProduct(
                      name: _productCtrl.text.trim(),
                      price: double.tryParse(_priceCtrl.text) ?? 0,
                      unit: _unit,
                    ),
                  );
              setState(() {
                _productCtrl.clear();
                _priceCtrl.clear();
              });
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Fiyat eklendi')));
            },
            child: const Text('KAYDET'),
          ),
        ],
      ),
    );
  }
}

class _CompareTab extends ConsumerStatefulWidget {
  const _CompareTab();

  @override
  ConsumerState<_CompareTab> createState() => _CompareTabState();
}

class _CompareTabState extends ConsumerState<_CompareTab> {
  String? _productName;

  @override
  Widget build(BuildContext context) {
    final suppliers = ref.watch(suppliersProvider);
    final productNames = <String>{
      for (final s in suppliers) for (final p in s.products) p.name,
    }.toList();

    final matches = <MapEntry<String, SupplierProduct>>[];
    if (_productName != null) {
      for (final s in suppliers) {
        for (final p in s.products) {
          if (p.name == _productName) matches.add(MapEntry(s.name, p));
        }
      }
      matches.sort((a, b) => a.value.price.compareTo(b.value.price));
    }

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Fiyat Karşılaştır', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          LabeledField(
            label: 'Ürün Seç',
            width: 280,
            child: DropdownButtonFormField<String>(
              initialValue: _productName,
              hint: const Text('— Seçin —'),
              items: [
                for (final name in productNames) DropdownMenuItem(value: name, child: Text(name)),
              ],
              onChanged: (v) => setState(() => _productName = v),
            ),
          ),
          const SizedBox(height: 20),
          for (var i = 0; i < matches.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: i == 0 ? const Color(0xFFE9F7EF) : AppColors.background,
                  border: Border.all(color: i == 0 ? AppColors.success : AppColors.border),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${matches[i].key}: ${Formatters.currency(matches[i].value.price)} / ${matches[i].value.unit}'
                  '${i == 0 ? "  (en uygun)" : ""}',
                  style: TextStyle(fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w500),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

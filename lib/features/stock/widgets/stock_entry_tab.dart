import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/stock_models.dart';
import '../../../data/providers/stock_provider.dart';
import '../../../shared/widgets/labeled_field.dart';
import '../../../shared/widgets/section_card.dart';

class StockEntryTab extends ConsumerStatefulWidget {
  const StockEntryTab({super.key});

  @override
  ConsumerState<StockEntryTab> createState() => _StockEntryTabState();
}

class _StockEntryTabState extends ConsumerState<StockEntryTab> {
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController(text: '0');
  String _unit = 'metre';
  final _minStockCtrl = TextEditingController(text: '10');
  final _supplierCtrl = TextEditingController();
  final _supplierPhoneCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(text: '0');
  final _descCtrl = TextEditingController();

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Ürün adı zorunludur')));
      return;
    }
    final notifier = ref.read(stockProvider.notifier);
    notifier.addItem(StockItem(
      id: notifier.nextId(),
      code: _codeCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      brand: _brandCtrl.text.trim(),
      category: _categoryCtrl.text.trim(),
      quantity: double.tryParse(_quantityCtrl.text) ?? 0,
      unit: _unit,
      minStock: double.tryParse(_minStockCtrl.text) ?? 0,
      supplierName: _supplierCtrl.text.trim(),
      purchasePrice: double.tryParse(_priceCtrl.text) ?? 0,
      description: _descCtrl.text.trim(),
      lastUpdated: DateTime.now(),
    ));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Stok kaydı eklendi')));
    setState(() {
      _codeCtrl.clear();
      _nameCtrl.clear();
      _brandCtrl.clear();
      _categoryCtrl.clear();
      _quantityCtrl.text = '0';
      _minStockCtrl.text = '10';
      _supplierCtrl.clear();
      _supplierPhoneCtrl.clear();
      _priceCtrl.text = '0';
      _descCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Yeni Stok Girişi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 18),
          FieldRow(children: [
            LabeledField(label: 'Ürün Kodu', width: 160, child: TextField(controller: _codeCtrl)),
            LabeledField(label: 'Ürün Adı *', width: 260, child: TextField(controller: _nameCtrl)),
            LabeledField(label: 'Marka', width: 200, child: TextField(controller: _brandCtrl)),
            LabeledField(label: 'Kategori', width: 160, child: TextField(controller: _categoryCtrl)),
          ]),
          const SizedBox(height: 16),
          FieldRow(children: [
            LabeledField(
              label: 'Miktar *',
              width: 140,
              child: TextField(controller: _quantityCtrl, keyboardType: TextInputType.number),
            ),
            LabeledField(
              label: 'Birim',
              width: 140,
              child: DropdownButtonFormField<String>(
                initialValue: _unit,
                items: const [
                  DropdownMenuItem(value: 'metre', child: Text('metre')),
                  DropdownMenuItem(value: 'adet', child: Text('adet')),
                  DropdownMenuItem(value: 'top', child: Text('top')),
                ],
                onChanged: (v) => setState(() => _unit = v!),
              ),
            ),
            LabeledField(
              label: 'Min Stok',
              width: 140,
              child: TextField(controller: _minStockCtrl, keyboardType: TextInputType.number),
            ),
            LabeledField(label: 'Tedarikçi', width: 200, child: TextField(controller: _supplierCtrl)),
            LabeledField(
                label: 'Tedarikçi Tel', width: 180, child: TextField(controller: _supplierPhoneCtrl)),
            LabeledField(
              label: 'Alış Fiyatı (TL)',
              width: 150,
              child: TextField(controller: _priceCtrl, keyboardType: TextInputType.number),
            ),
          ]),
          const SizedBox(height: 16),
          LabeledField(label: 'Açıklama', child: TextField(controller: _descCtrl)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _save, child: const Text('KAYDET')),
        ],
      ),
    );
  }
}

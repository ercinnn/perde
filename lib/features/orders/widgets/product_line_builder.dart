import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/calc/pricing_calculator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/order_models.dart';
import '../../../data/providers/planning_provider.dart';
import '../../../shared/widgets/labeled_field.dart';
import '../../../shared/widgets/section_card.dart';

/// Reusable "Ürün Ekle" + "Eklenen Ürünler" block, used by both the Sipariş
/// and Teklif tabs of the order form.
class ProductLineBuilder extends ConsumerStatefulWidget {
  const ProductLineBuilder({
    super.key,
    required this.items,
    required this.onChanged,
  });

  final List<OrderItem> items;
  final ValueChanged<List<OrderItem>> onChanged;

  @override
  ConsumerState<ProductLineBuilder> createState() => _ProductLineBuilderState();
}

class _ProductLineBuilderState extends ConsumerState<ProductLineBuilder> {
  ProductType? _productType;
  RoomType _room = RoomType.salon;
  final _codeCtrl = TextEditingController();
  final _widthCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  String? _pileFeeId;
  final _pilePercentCtrl = TextEditingController();
  bool _alsoAddGuneslik = false;
  final _unitPriceCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController(text: '1');
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    _widthCtrl.dispose();
    _heightCtrl.dispose();
    _pilePercentCtrl.dispose();
    _unitPriceCtrl.dispose();
    _quantityCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  double _num(TextEditingController c) => double.tryParse(c.text.replaceAll(',', '.')) ?? 0;

  void _addItem() {
    if (_productType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen ürün tipi seçin')),
      );
      return;
    }
    final pileFees = ref.read(pileFeesProvider);
    final pileFee = pileFees.where((f) => f.id == _pileFeeId).toList();
    final pileFeeAmount = pileFee.isEmpty ? 0.0 : pileFee.first.price;
    final pileLabel = pileFee.isEmpty ? null : pileFee.first.name;

    final width = _num(_widthCtrl);
    final height = _num(_heightCtrl);
    final unitPrice = _num(_unitPriceCtrl);
    final quantity = int.tryParse(_quantityCtrl.text) ?? 1;
    final pilePercent = _num(_pilePercentCtrl);

    final baseTotal = PricingCalculator.compute(
      category: _productType!.category,
      width: width,
      height: height,
      pilePercent: pilePercent,
      unitPrice: unitPrice,
    );
    final total = (baseTotal + pileFeeAmount) * quantity;

    final newItems = [
      ...widget.items,
      OrderItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        productType: _productType!,
        room: _room,
        productCode: _codeCtrl.text,
        width: width,
        height: height,
        pileType: pileLabel,
        pilePercent: pilePercent,
        unitPrice: unitPrice,
        quantity: quantity,
        note: _noteCtrl.text,
        total: total,
      ),
    ];

    if (_alsoAddGuneslik && _productType != ProductType.guneslik) {
      final gTotal =
          PricingCalculator.compute(
            category: PricingCategory.guneslikBlackout,
            width: width,
            height: height,
            pilePercent: 0,
            unitPrice: unitPrice,
          ) *
          quantity;
      newItems.add(OrderItem(
        id: '${DateTime.now().microsecondsSinceEpoch}-g',
        productType: ProductType.guneslik,
        room: _room,
        productCode: _codeCtrl.text,
        width: width,
        height: height,
        unitPrice: unitPrice,
        quantity: quantity,
        note: 'Otomatik eklendi',
        total: gTotal,
      ));
    }

    widget.onChanged(newItems);

    setState(() {
      _productType = null;
      _codeCtrl.clear();
      _widthCtrl.clear();
      _heightCtrl.clear();
      _pileFeeId = null;
      _pilePercentCtrl.clear();
      _alsoAddGuneslik = false;
      _unitPriceCtrl.clear();
      _quantityCtrl.text = '1';
      _noteCtrl.clear();
    });
  }

  void _removeItem(String id) {
    widget.onChanged(widget.items.where((i) => i.id != id).toList());
  }

  @override
  Widget build(BuildContext context) {
    final pileFees = ref.watch(pileFeesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ürün Ekle',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FieldRow(children: [
                LabeledField(
                  label: 'Ürün Tipi',
                  width: 190,
                  child: DropdownButtonFormField<ProductType>(
                    initialValue: _productType,
                    hint: const Text('— Seçin —'),
                    items: [
                      for (final p in ProductType.values)
                        DropdownMenuItem(value: p, child: Text(p.label)),
                    ],
                    onChanged: (v) => setState(() => _productType = v),
                  ),
                ),
                LabeledField(
                  label: 'Oda',
                  width: 190,
                  child: DropdownButtonFormField<RoomType>(
                    initialValue: _room,
                    items: [
                      for (final r in RoomType.values)
                        DropdownMenuItem(value: r, child: Text(r.label)),
                    ],
                    onChanged: (v) => setState(() => _room = v!),
                  ),
                ),
                LabeledField(
                  label: 'Ürün Kodu',
                  width: 150,
                  child: TextField(controller: _codeCtrl),
                ),
                LabeledField(
                  label: 'En (m)',
                  width: 110,
                  child: TextField(
                    controller: _widthCtrl,
                    keyboardType: TextInputType.number,
                  ),
                ),
                LabeledField(
                  label: 'Boy (m)',
                  width: 110,
                  child: TextField(
                    controller: _heightCtrl,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              FieldRow(children: [
                LabeledField(
                  label: 'Pile Çeşidi',
                  width: 240,
                  child: DropdownButtonFormField<String?>(
                    initialValue: _pileFeeId,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('-- Pile Yok --')),
                      for (final f in pileFees)
                        DropdownMenuItem(
                          value: f.id,
                          child: Text('${f.name} (${Formatters.currency(f.price)})'),
                        ),
                    ],
                    onChanged: (v) => setState(() => _pileFeeId = v),
                  ),
                ),
                LabeledField(
                  label: 'Pile Miktarı (%)',
                  width: 150,
                  child: TextField(
                    controller: _pilePercentCtrl,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              CheckboxListTile(
                value: _alsoAddGuneslik,
                onChanged: (v) => setState(() => _alsoAddGuneslik = v ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('☀️ Aynı ölçüyle güneşlik de ekle'),
              ),
              const SizedBox(height: 6),
              FieldRow(children: [
                LabeledField(
                  label: 'Birim Fiyat (TL)',
                  width: 160,
                  child: TextField(
                    controller: _unitPriceCtrl,
                    keyboardType: TextInputType.number,
                  ),
                ),
                LabeledField(
                  label: 'Adet',
                  width: 100,
                  child: TextField(
                    controller: _quantityCtrl,
                    keyboardType: TextInputType.number,
                  ),
                ),
                LabeledField(
                  label: 'Not',
                  width: 240,
                  child: TextField(controller: _noteCtrl),
                ),
              ]),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _addItem, child: const Text('ÜRÜNÜ EKLE')),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Eklenen Ürünler',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        if (widget.items.isEmpty)
          const Text('Henüz ürün eklenmedi.', style: TextStyle(color: AppColors.textMuted)),
        for (final item in widget.items)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${item.productType.label} (${item.room.label}) — ${Formatters.currency(item.total)}',
                  ),
                ),
                InkWell(
                  onTap: () => _removeItem(item.id),
                  child: const Icon(Icons.close, color: AppColors.danger, size: 18),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

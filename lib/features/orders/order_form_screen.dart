import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/mock_clock.dart';
import '../../data/models/enums.dart';
import '../../data/models/order_models.dart';
import '../../data/providers/orders_provider.dart';
import '../../shared/widgets/labeled_field.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/section_card.dart';
import 'widgets/order_summary_dialog.dart';
import 'widgets/product_line_builder.dart';

class OrderFormScreen extends ConsumerStatefulWidget {
  const OrderFormScreen({super.key});

  @override
  ConsumerState<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends ConsumerState<OrderFormScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Sipariş Formu',
      icon: '📋',
      actions: [
        OutlinedButton(
          onPressed: () => setState(() {}),
          child: const Text('🖨️ Boş Form'),
        ),
        OutlinedButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fotoğraf Yükle (Pro) — demo')),
          ),
          child: const Text('📷 Fotoğraf Yükle  Pro'),
        ),
        OutlinedButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ölçü fotoğrafı eklendi (demo)')),
          ),
          child: const Text('📐 Ölçü Fotoğrafı Ekle'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _TabButton(
                  label: 'Sipariş',
                  active: _tab == 0,
                  onTap: () => setState(() => _tab = 0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TabButton(
                  label: 'Ölçü',
                  active: _tab == 1,
                  onTap: () => setState(() => _tab = 1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TabButton(
                  label: 'Teklif',
                  active: _tab == 2,
                  onTap: () => setState(() => _tab = 2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          IndexedStack(
            index: _tab,
            children: const [
              _OrderTab(),
              _MeasurementTab(),
              _QuoteTab(),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: active ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _OrderTab extends ConsumerStatefulWidget {
  const _OrderTab();

  @override
  ConsumerState<_OrderTab> createState() => _OrderTabState();
}

class _OrderTabState extends ConsumerState<_OrderTab> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  DateTime _deliveryDate = mockToday.add(const Duration(days: 7));
  DeliveryType _deliveryType = DeliveryType.montaj;
  final _planTimeCtrl = TextEditingController(text: '09.00');
  final _depositCtrl = TextEditingController(text: '0');
  final _discountCtrl = TextEditingController(text: '0');
  List<OrderItem> _items = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _planTimeCtrl.dispose();
    _depositCtrl.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  double get _subtotal => _items.fold(0, (s, i) => s + i.total);
  double get _discount => double.tryParse(_discountCtrl.text.replaceAll(',', '.')) ?? 0;
  double get _deposit => double.tryParse(_depositCtrl.text.replaceAll(',', '.')) ?? 0;
  double get _total => (_subtotal - _discount).clamp(0, double.infinity);
  double get _remaining => (_total - _deposit).clamp(0, double.infinity);

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Müşteri adı zorunludur')));
      return;
    }
    final notifier = ref.read(ordersProvider.notifier);
    final order = Order(
      id: 'ord-${DateTime.now().microsecondsSinceEpoch}',
      code: notifier.nextCode(),
      customerName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      orderDate: mockToday,
      deliveryDate: _deliveryDate,
      deliveryType: _deliveryType,
      planTime: _planTimeCtrl.text.trim(),
      items: _items,
      deposit: _deposit,
      discount: _discount,
    );
    try {
      await notifier.addOrder(order);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Sipariş kaydedilemedi: $e')));
      return;
    }
    if (!mounted) return;
    showOrderSummaryDialog(context, order);
    setState(() {
      _nameCtrl.clear();
      _phoneCtrl.clear();
      _addressCtrl.clear();
      _items = [];
      _depositCtrl.text = '0';
      _discountCtrl.text = '0';
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deliveryDate,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2027, 12, 31),
    );
    if (picked != null) setState(() => _deliveryDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Yeni Sipariş',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 18),
          LabeledField(
            label: 'Müşteri Adı *',
            child: TextField(controller: _nameCtrl),
          ),
          const SizedBox(height: 16),
          FieldRow(children: [
            LabeledField(
              label: 'Telefon',
              width: 200,
              child: TextField(controller: _phoneCtrl),
            ),
            LabeledField(
              label: 'Adres',
              width: 260,
              child: TextField(controller: _addressCtrl),
            ),
            LabeledField(
              label: 'Teslim Tarihi',
              width: 150,
              child: InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(),
                  child: Text(Formatters.date(_deliveryDate)),
                ),
              ),
            ),
            LabeledField(
              label: 'Teslimat Tipi',
              width: 160,
              child: DropdownButtonFormField<DeliveryType>(
                initialValue: _deliveryType,
                items: [
                  for (final d in DeliveryType.values)
                    DropdownMenuItem(value: d, child: Text(d.label)),
                ],
                onChanged: (v) => setState(() => _deliveryType = v!),
              ),
            ),
            LabeledField(
              label: 'Plan Saati',
              width: 110,
              child: TextField(controller: _planTimeCtrl),
            ),
          ]),
          const SizedBox(height: 24),
          ProductLineBuilder(
            items: _items,
            onChanged: (items) => setState(() => _items = items),
          ),
          const SizedBox(height: 24),
          const Text('Ödeme Özeti',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          FieldRow(children: [
            LabeledField(
              label: 'Kapora (TL)',
              width: 180,
              child: TextField(
                controller: _depositCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ),
            LabeledField(
              label: 'İndirim (TL)',
              width: 180,
              child: TextField(
                controller: _discountCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          Text('Toplam: ${Formatters.currency(_total)}   |   Kalan: ${Formatters.currency(_remaining)}',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _save, child: const Text('SİPARİŞİ KAYDET')),
        ],
      ),
    );
  }
}

class _MeasurementTab extends StatelessWidget {
  const _MeasurementTab();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ölçü / Sipariş Notu',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ElevatedButton(
                onPressed: () => ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Yazdırılıyor (demo)'))),
                child: const Text('🖨️ Yazdır'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Perde360 — bu formu doldurup fotoğrafını Sipariş Formu\'ndaki "Fotoğraftan Doldur" ile yükleyin.',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          FieldRow(children: [
            LabeledField(label: 'Müşteri Adı Soyadı', width: 260, child: TextField()),
            LabeledField(label: 'Telefon', width: 200, child: TextField()),
          ]),
          const SizedBox(height: 12),
          const LabeledField(label: 'Adres', child: TextField()),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ürün Tipi Kodları:', style: TextStyle(fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text(
                    'T=Tül  F=Fon  G=Güneşlik  B=Blackout  KR=Karartma  S=Stor  Z=Zebra  '
                    'P=Pliseli  AJ=Ahşap Jaluzi  AL=Alüminyum Jaluzi  K=Korniş  D=Dikey Perde'),
                SizedBox(height: 10),
                Text('Oda Kodları:', style: TextStyle(fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text(
                    'SL=Salon  OO=Oturma Odası  YO=Yatak Odası  MU=Mutfak  CO=Çocuk Odası  '
                    'AO=Arka Oda  BL=Balkon  CA=Çalışma Odası  KA=Koridor/Antre'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              border: TableBorder.all(color: AppColors.border),
              defaultColumnWidth: const FixedColumnWidth(90),
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: AppColors.background),
                  children: [
                    for (final h in ['#', 'ODA', 'TİP', 'EN (M)', 'BOY (M)', 'ADET', 'PİLE', 'FİYAT (TL)', 'NOT'])
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(h, style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                  ],
                ),
                for (var i = 1; i <= 10; i++)
                  TableRow(children: [
                    Padding(padding: const EdgeInsets.all(8), child: Text('$i')),
                    for (var c = 0; c < 8; c++)
                      const Padding(
                        padding: EdgeInsets.all(4),
                        child: SizedBox(height: 32, child: TextField()),
                      ),
                  ]),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const FieldRow(children: [
            LabeledField(label: 'TOPLAM (TL)', width: 180, child: TextField()),
            LabeledField(label: 'KAPORA (TL)', width: 180, child: TextField()),
            LabeledField(label: 'KALAN (TL)', width: 180, child: TextField()),
          ]),
        ],
      ),
    );
  }
}

class _QuoteTab extends ConsumerStatefulWidget {
  const _QuoteTab();

  @override
  ConsumerState<_QuoteTab> createState() => _QuoteTabState();
}

class _QuoteTabState extends ConsumerState<_QuoteTab> {
  final _nameCtrl = TextEditingController();
  List<OrderItem> _items = [];

  double get _total => _items.fold(0, (s, i) => s + i.total);

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Yeni Teklif',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text(
            'Teklif, stok/kapora takibi yapmadan sadece fiyat özeti oluşturur.',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          LabeledField(label: 'Müşteri Adı', width: 320, child: TextField(controller: _nameCtrl)),
          const SizedBox(height: 20),
          ProductLineBuilder(
            items: _items,
            onChanged: (items) => setState(() => _items = items),
          ),
          const SizedBox(height: 16),
          Text('Teklif Toplamı: ${Formatters.currency(_total)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Teklif oluşturuldu: ${Formatters.currency(_total)}')),
            ),
            child: const Text('TEKLİF OLUŞTUR'),
          ),
        ],
      ),
    );
  }
}

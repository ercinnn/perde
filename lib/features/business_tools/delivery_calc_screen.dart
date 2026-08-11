import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/mock_clock.dart';
import '../../data/models/enums.dart';
import '../../data/providers/orders_provider.dart';
import '../../shared/widgets/labeled_field.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/section_card.dart';

class DeliveryCalcScreen extends ConsumerStatefulWidget {
  const DeliveryCalcScreen({super.key});

  @override
  ConsumerState<DeliveryCalcScreen> createState() => _DeliveryCalcScreenState();
}

class _DeliveryCalcScreenState extends ConsumerState<DeliveryCalcScreen> {
  final _capacityCtrl = TextEditingController();
  double? _workload;
  DateTime _startDate = mockToday;
  bool _saveCapacity = true;
  String? _resultText;

  double _pendingWorkload() {
    final orders = ref.read(ordersProvider);
    double total = 0;
    for (final o in orders) {
      if (o.status != OrderStatus.bekliyor) continue;
      for (final item in o.items) {
        total += item.width;
      }
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    _workload = _pendingWorkload();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2027, 12, 31),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  void _calculate() {
    final capacity = double.tryParse(_capacityCtrl.text.replaceAll(',', '.')) ?? 0;
    if (capacity <= 0 || _workload == null) {
      setState(() => _resultText = 'Lütfen geçerli bir günlük kapasite girin.');
      return;
    }
    final days = (_workload! / capacity).ceil();
    final deliveryDate = _startDate.add(Duration(days: days));
    setState(() {
      _resultText =
          'Tahmini teslimat tarihi: ${Formatters.date(deliveryDate)}  ($days iş günü)';
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Teslimat Tarihi Hesaplama',
      icon: '🗓️',
      child: SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Günlük dikiş kapasitenize göre tahmini teslimat tarihini hesaplar.'),
            const SizedBox(height: 20),
            LabeledField(
              label: 'Günlük dikiş kapasitesi (mt/gün)',
              width: 260,
              child: TextField(controller: _capacityCtrl, keyboardType: TextInputType.number),
            ),
            const SizedBox(height: 16),
            const Text('Mevcut bekleyen iş yükü (mt)',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 6),
            Row(
              children: [
                Text('${_workload?.toStringAsFixed(1) ?? 0} mt',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.orange)),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () => setState(() => _workload = _pendingWorkload()),
                  child: const Text('Değiştir'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text('(sipariş verilerinden otomatik hesaplanır)',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            LabeledField(
              label: 'Başlangıç tarihi',
              width: 200,
              child: InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(),
                  child: Text(Formatters.date(_startDate)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            CheckboxListTile(
              value: _saveCapacity,
              onChanged: (v) => setState(() => _saveCapacity = v ?? true),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Günlük kapasiteyi kaydet'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _calculate, child: const Text('📅 TESLİMAT TARİHİ HESAPLA')),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F7F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_resultText ?? 'Hesaplamak için butona basın.'),
            ),
          ],
        ),
      ),
    );
  }
}

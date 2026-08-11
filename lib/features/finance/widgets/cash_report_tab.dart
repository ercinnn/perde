import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/mock_clock.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/finance_models.dart';
import '../../../data/providers/finance_provider.dart';
import '../../../shared/widgets/labeled_field.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/stat_card.dart';

class CashReportTab extends ConsumerStatefulWidget {
  const CashReportTab({super.key});

  @override
  ConsumerState<CashReportTab> createState() => _CashReportTabState();
}

class _CashReportTabState extends ConsumerState<CashReportTab> {
  DateTime _selectedDate = mockToday;
  CashType _type = CashType.gelir;
  final _categoryCtrl = TextEditingController(text: 'Elden Satis');
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2027, 12, 31),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(cashRecordsProvider.notifier);
    final all = ref.watch(cashRecordsProvider);
    final dayRecords = all
        .where((r) =>
            r.time.year == _selectedDate.year &&
            r.time.month == _selectedDate.month &&
            r.time.day == _selectedDate.day)
        .toList()
        .reversed
        .toList();
    final income = notifier.totalFor(CashType.gelir, _selectedDate);
    final expense = notifier.totalFor(CashType.gider, _selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldRow(children: [
          LabeledField(
            label: 'Tarih',
            width: 160,
            child: InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(),
                child: Text(Formatters.date(_selectedDate)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: ElevatedButton(onPressed: () => setState(() {}), child: const Text('GÖSTER')),
          ),
        ]),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            StatCard(value: Formatters.currency(income), label: 'TOPLAM GELİR', color: AppColors.success),
            StatCard(value: Formatters.currency(expense), label: 'TOPLAM GİDER', color: AppColors.danger),
            StatCard(
                value: Formatters.currency(income - expense),
                label: 'NET KASA',
                color: const Color(0xFFC9A227)),
          ],
        ),
        const SizedBox(height: 20),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Yeni Kasa Kaydı',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              FieldRow(children: [
                LabeledField(
                  label: 'Tip',
                  width: 160,
                  child: DropdownButtonFormField<CashType>(
                    initialValue: _type,
                    items: [
                      for (final t in CashType.values)
                        DropdownMenuItem(value: t, child: Text(t.label)),
                    ],
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                ),
                LabeledField(
                  label: 'Kategori',
                  width: 180,
                  child: TextField(controller: _categoryCtrl),
                ),
                LabeledField(
                  label: 'Tutar (TL) *',
                  width: 160,
                  child: TextField(controller: _amountCtrl, keyboardType: TextInputType.number),
                ),
                LabeledField(
                  label: 'Açıklama',
                  width: 220,
                  child: TextField(controller: _descCtrl),
                ),
              ]),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(_amountCtrl.text) ?? 0;
                  if (amount <= 0) return;
                  notifier.addRecord(CashRecord(
                    id: notifier.nextId(),
                    type: _type,
                    category: _categoryCtrl.text.trim(),
                    amount: amount,
                    description: _descCtrl.text.trim(),
                    time: _selectedDate,
                  ));
                  setState(() {
                    _amountCtrl.clear();
                    _descCtrl.clear();
                  });
                },
                child: const Text('KAYDET'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final r in dayRecords)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SectionCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${r.category} — ${Formatters.currency(r.amount)}',
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                        if (r.description.isNotEmpty)
                          Text(r.description, style: const TextStyle(color: Colors.grey, fontSize: 12.5)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: r.type == CashType.gelir ? AppColors.success : AppColors.danger,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(r.type.label.toLowerCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => notifier.removeRecord(r.id),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

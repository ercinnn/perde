import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/finance_models.dart';
import '../../../data/providers/finance_provider.dart';
import '../../../shared/widgets/labeled_field.dart';
import '../../../shared/widgets/section_card.dart';

class InstallmentsTab extends ConsumerWidget {
  const InstallmentsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(installmentsProvider);
    final total = plans.fold<double>(0, (s, p) => s + p.totalAmount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          child: Text(
            'Toplam Taksitli Satış: ${Formatters.currency(total)} | Tahsil Edilecek: ${Formatters.currency(total)} | Plan: ${plans.length} adet',
            style: const TextStyle(color: Color(0xFF2E9E5B), fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _showForm(context, ref),
              child: const Text('+ Yeni Taksit Planı'),
            ),
            const SizedBox(width: 10),
            OutlinedButton(onPressed: () {}, child: const Text('↻ Yenile')),
          ],
        ),
        const SizedBox(height: 16),
        if (plans.isEmpty)
          const SectionCard(child: Text('Henüz taksit planı yok.'))
        else
          for (final p in plans)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SectionCard(
                child: Text(
                  '${p.customerName} — ${Formatters.currency(p.totalAmount)} / ${p.installmentCount} taksit',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
      ],
    );
  }

  void _showForm(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final countCtrl = TextEditingController(text: '2');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Yeni Taksit Planı',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                LabeledField(label: 'Müşteri Adı *', child: TextField(controller: nameCtrl)),
                const SizedBox(height: 14),
                FieldRow(children: [
                  LabeledField(
                    label: 'Toplam Tutar (TL)',
                    width: 200,
                    child: TextField(controller: amountCtrl, keyboardType: TextInputType.number),
                  ),
                  LabeledField(
                    label: 'Taksit Sayısı',
                    width: 140,
                    child: TextField(controller: countCtrl, keyboardType: TextInputType.number),
                  ),
                ]),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('İptal')),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (nameCtrl.text.trim().isEmpty) return;
                        final notifier = ref.read(installmentsProvider.notifier);
                        notifier.addPlan(InstallmentPlan(
                          id: notifier.nextId(),
                          customerName: nameCtrl.text.trim(),
                          totalAmount: double.tryParse(amountCtrl.text) ?? 0,
                          installmentCount: int.tryParse(countCtrl.text) ?? 1,
                          startDate: DateTime.now(),
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
    );
  }
}

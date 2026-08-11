import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/finance_models.dart';
import '../../../data/providers/finance_provider.dart';
import '../../../shared/widgets/labeled_field.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_badge.dart';

class ReceivablesTab extends ConsumerWidget {
  const ReceivablesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receivables = ref.watch(receivablesProvider);
    final total = receivables.fold<double>(0, (s, r) => s + r.total);
    final remaining = receivables.fold<double>(0, (s, r) => s + r.remaining);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          child: Text(
            'Toplam Veresiye: ${Formatters.currency(total)} | Tahsil Edilecek: ${Formatters.currency(remaining)} | Kayıt: ${receivables.length} adet',
            style: const TextStyle(color: Color(0xFF2E9E5B), fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _showForm(context, ref),
              child: const Text('+ Yeni Veresiye'),
            ),
            const SizedBox(width: 10),
            OutlinedButton(onPressed: () {}, child: const Text('↻ Yenile')),
          ],
        ),
        const SizedBox(height: 16),
        for (final r in receivables)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SectionCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${r.customerName} — ${Formatters.currency(r.remaining)} kalan',
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text('Toplam: ${Formatters.currency(r.total)} · Vade: ${Formatters.date(r.dueDate)}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12.5)),
                      ],
                    ),
                  ),
                  StatusBadge(
                    label: r.status.label,
                    tone: r.status == PaymentStatus.odendi ? BadgeTone.green : BadgeTone.orange,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showForm(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final totalCtrl = TextEditingController();
    final remainingCtrl = TextEditingController();

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
                const Text('Yeni Veresiye Kaydı',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                LabeledField(label: 'Müşteri Adı *', child: TextField(controller: nameCtrl)),
                const SizedBox(height: 14),
                FieldRow(children: [
                  LabeledField(
                    label: 'Toplam (TL)',
                    width: 180,
                    child: TextField(controller: totalCtrl, keyboardType: TextInputType.number),
                  ),
                  LabeledField(
                    label: 'Kalan (TL)',
                    width: 180,
                    child: TextField(controller: remainingCtrl, keyboardType: TextInputType.number),
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
                        final notifier = ref.read(receivablesProvider.notifier);
                        notifier.addReceivable(Receivable(
                          id: notifier.nextId(),
                          customerName: nameCtrl.text.trim(),
                          total: double.tryParse(totalCtrl.text) ?? 0,
                          remaining: double.tryParse(remainingCtrl.text) ?? 0,
                          dueDate: DateTime.now().add(const Duration(days: 30)),
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

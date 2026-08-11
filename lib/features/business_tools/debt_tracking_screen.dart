import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/enums.dart';
import '../../data/models/finance_models.dart';
import '../../data/providers/finance_provider.dart';
import '../../shared/widgets/labeled_field.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/section_card.dart';
import '../../shared/widgets/status_badge.dart';

class DebtTrackingScreen extends ConsumerWidget {
  const DebtTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debts = ref.watch(debtsProvider);
    final total = debts.fold<double>(0, (s, d) => s + d.total);
    final remaining = debts.fold<double>(0, (s, d) => s + d.remaining);

    return PageScaffold(
      title: 'Borç Ödeme Takibi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionCard(
            child: Text(
              'Toplam Borç: ${Formatters.currency(total)} | Ödenecek: ${Formatters.currency(remaining)} | Kayıt: ${debts.length} adet',
              style: const TextStyle(color: Color(0xFFC0392B), fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => _showForm(context, ref),
                child: const Text('+ Yeni Borç'),
              ),
              const SizedBox(width: 10),
              OutlinedButton(onPressed: () {}, child: const Text('↻ Yenile')),
            ],
          ),
          const SizedBox(height: 16),
          for (final d in debts)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SectionCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${d.supplierName} — ${Formatters.currency(d.remaining)} kalan',
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text('${d.description} · Toplam: ${Formatters.currency(d.total)} · Vade: ${Formatters.date(d.dueDate)}',
                              style: const TextStyle(color: Colors.grey, fontSize: 12.5)),
                        ],
                      ),
                    ),
                    StatusBadge(
                      label: d.status.label,
                      tone: d.status == PaymentStatus.odendi ? BadgeTone.green : BadgeTone.orange,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showForm(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Yeni Borç Kaydı', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                LabeledField(label: 'Tedarikçi Adı *', child: TextField(controller: nameCtrl)),
                const SizedBox(height: 14),
                LabeledField(label: 'Açıklama', child: TextField(controller: descCtrl)),
                const SizedBox(height: 14),
                LabeledField(
                  label: 'Borç Tutarı (TL) *',
                  width: 200,
                  child: TextField(controller: amountCtrl, keyboardType: TextInputType.number),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('İptal')),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (nameCtrl.text.trim().isEmpty) return;
                        final amount = double.tryParse(amountCtrl.text) ?? 0;
                        final notifier = ref.read(debtsProvider.notifier);
                        notifier.addDebt(Debt(
                          id: notifier.nextId(),
                          supplierName: nameCtrl.text.trim(),
                          description: descCtrl.text.trim(),
                          total: amount,
                          remaining: amount,
                          dueDate: DateTime.now().add(const Duration(days: 30)),
                        ));
                        Navigator.of(context).pop();
                      },
                      child: const Text('BORÇ KAYDET'),
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

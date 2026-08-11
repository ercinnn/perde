import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/finance_models.dart';
import '../../../data/providers/finance_provider.dart';
import '../../../shared/widgets/labeled_field.dart';
import '../../../shared/widgets/section_card.dart';

class RemindersTab extends ConsumerWidget {
  const RemindersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(remindersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _showForm(context, ref),
              child: const Text('+ Yeni Hatırlatma'),
            ),
            const SizedBox(width: 10),
            OutlinedButton(onPressed: () {}, child: const Text('↻ Yenile')),
          ],
        ),
        const SizedBox(height: 16),
        if (reminders.isEmpty)
          const SectionCard(child: Text('Henüz hatırlatma yok.'))
        else
          for (final r in reminders)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text('Vade: ${Formatters.date(r.dueDate)}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12.5)),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  void _showForm(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Yeni Ödeme Hatırlatma',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                LabeledField(label: 'Başlık *', child: TextField(controller: titleCtrl)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('İptal')),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (titleCtrl.text.trim().isEmpty) return;
                        final notifier = ref.read(remindersProvider.notifier);
                        notifier.addReminder(PaymentReminder(
                          id: notifier.nextId(),
                          title: titleCtrl.text.trim(),
                          dueDate: DateTime.now().add(const Duration(days: 7)),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/mock_clock.dart';
import '../../data/models/enums.dart';
import '../../data/models/planning_models.dart';
import '../../data/providers/planning_provider.dart';
import '../../shared/widgets/labeled_field.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/section_card.dart';

const _dayLabels = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi'];

class WeeklyPlanScreen extends ConsumerStatefulWidget {
  const WeeklyPlanScreen({super.key});

  @override
  ConsumerState<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends ConsumerState<WeeklyPlanScreen> {
  DeliveryType _type = DeliveryType.montaj;
  int _weekOffset = 0;

  DateTime get _monday {
    final base = mockToday.subtract(Duration(days: mockToday.weekday - 1));
    return base.add(Duration(days: 7 * _weekOffset));
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(weeklyPlanProvider);
    final monday = _monday;
    final saturday = monday.add(const Duration(days: 5));

    return PageScaffold(
      title: 'Haftalık Program',
      icon: '🗓️',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ToggleButton(
                label: 'Montaj Programı',
                active: _type == DeliveryType.montaj,
                onTap: () => setState(() => _type = DeliveryType.montaj),
              ),
              _ToggleButton(
                label: 'Elden Teslim',
                active: _type == DeliveryType.eldenTeslim,
                onTap: () => setState(() => _type = DeliveryType.eldenTeslim),
              ),
              ElevatedButton(
                onPressed: () => _showForm(context, monday),
                child: const Text('+ Yeni Plan'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              OutlinedButton(
                onPressed: () => setState(() => _weekOffset -= 1),
                child: const Text('‹ Önceki'),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${Formatters.date(monday)} — ${Formatters.date(saturday)}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () => setState(() => _weekOffset = 0),
                child: const Text('Bu Hafta'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => setState(() => _weekOffset += 1),
                child: const Text('Sonraki ›'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              for (var i = 0; i < 6; i++) _DayCard(
                date: monday.add(Duration(days: i)),
                label: _dayLabels[i],
                isToday: _isSameDay(monday.add(Duration(days: i)), mockToday),
                entries: entries
                    .where((e) => e.type == _type && _isSameDay(e.date, monday.add(Duration(days: i))))
                    .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _showForm(BuildContext context, DateTime monday) {
    DateTime selectedDate = mockToday;
    final timeCtrl = TextEditingController(text: '09.00');
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    var type = _type;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Yeni Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  LabeledField(
                    label: 'Gün',
                    child: DropdownButtonFormField<int>(
                      initialValue: 0,
                      items: [
                        for (var i = 0; i < 6; i++)
                          DropdownMenuItem(value: i, child: Text('${_dayLabels[i]} (${Formatters.date(monday.add(Duration(days: i)))})')),
                      ],
                      onChanged: (v) => setStateDialog(() => selectedDate = monday.add(Duration(days: v!))),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FieldRow(children: [
                    LabeledField(label: 'Saat', width: 120, child: TextField(controller: timeCtrl)),
                    LabeledField(
                      label: 'Tip',
                      width: 180,
                      child: DropdownButtonFormField<DeliveryType>(
                        initialValue: type,
                        items: const [
                          DropdownMenuItem(value: DeliveryType.montaj, child: Text('Montaj')),
                          DropdownMenuItem(value: DeliveryType.eldenTeslim, child: Text('Elden Teslim')),
                        ],
                        onChanged: (v) => setStateDialog(() => type = v!),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  LabeledField(label: 'Müşteri Adı *', child: TextField(controller: nameCtrl)),
                  const SizedBox(height: 14),
                  LabeledField(label: 'Açıklama', child: TextField(controller: descCtrl)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('İptal')),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (nameCtrl.text.trim().isEmpty) return;
                          final notifier = ref.read(weeklyPlanProvider.notifier);
                          notifier.addEntry(WeeklyPlanEntry(
                            id: notifier.nextId(),
                            date: selectedDate,
                            time: timeCtrl.text.trim(),
                            customerName: nameCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                            type: type,
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
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: active ? AppColors.primary : null,
        foregroundColor: active ? Colors.white : AppColors.textPrimary,
        side: BorderSide(color: active ? AppColors.primary : AppColors.border),
      ),
      child: Text(label),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.date,
    required this.label,
    required this.isToday,
    required this.entries,
  });

  final DateTime date;
  final String label;
  final bool isToday;
  final List<WeeklyPlanEntry> entries;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label ${Formatters.date(date).substring(0, 5)}${isToday ? " (Bugün)" : ""}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isToday ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const Divider(height: 18),
            if (entries.isEmpty)
              const Text('Plan yok', style: TextStyle(color: AppColors.textMuted))
            else
              for (final e in entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${e.time} ${e.customerName}',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                        Text(e.description, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/mock_clock.dart';
import '../../data/models/enums.dart';
import '../../data/models/order_models.dart';
import '../../data/providers/finance_provider.dart';
import '../../data/providers/orders_provider.dart';
import '../../data/providers/planning_provider.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/section_card.dart';
import '../../shared/widgets/stat_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final cashRecords = ref.watch(cashRecordsProvider);
    final cashNotifier = ref.read(cashRecordsProvider.notifier);
    final receivables = ref.watch(receivablesProvider);
    final debts = ref.watch(debtsProvider);

    final pendingCount =
        orders.where((o) => o.status == OrderStatus.bekliyor).length;
    final todayIncome = cashNotifier.totalFor(CashType.gelir, mockToday);
    final todayExpense = cashNotifier.totalFor(CashType.gider, mockToday);
    final monthlyIncome = cashRecords
        .where((r) =>
            r.type == CashType.gelir &&
            r.time.year == mockToday.year &&
            r.time.month == mockToday.month)
        .fold<double>(0, (s, r) => s + r.amount);

    final totalReceivable = receivables.fold<double>(0, (s, r) => s + r.remaining);
    final totalDebt = debts.fold<double>(0, (s, d) => s + d.remaining);

    return PageScaffold(
      title: 'Kontrol Paneli',
      icon: '🏠',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              StatCard(
                value: '$pendingCount',
                label: 'Bekleyen Sipariş',
                color: AppColors.info,
              ),
              StatCard(
                value: Formatters.currency(todayIncome),
                label: 'Bugün Gelir',
                color: AppColors.success,
              ),
              StatCard(
                value: Formatters.currency(todayExpense),
                label: 'Bugün Gider',
                color: AppColors.danger,
              ),
              StatCard(
                value: Formatters.currency(monthlyIncome),
                label: 'Aylık Gelir',
                color: AppColors.purple,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Finansal Özet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Text(
                  'Veresiye Alacak: ${Formatters.currency(totalReceivable)}  |  '
                  'Tedarikçi Borç: ${Formatters.currency(totalDebt)}  |  '
                  'Bugün Net: ${Formatters.currency(todayIncome - todayExpense)}',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hızlı İşlemler',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton(
                      onPressed: () => context.go(Routes.orderForm),
                      child: const Text('📋 Yeni Sipariş'),
                    ),
                    ElevatedButton(
                      onPressed: () => context.go(Routes.stock),
                      child: const Text('📦 Stok & Tedarik'),
                    ),
                    ElevatedButton(
                      onPressed: () => context.go(Routes.finance),
                      child: const Text('💰 Finans'),
                    ),
                    ElevatedButton(
                      onPressed: () => context.go(Routes.weeklyPlan),
                      child: const Text('🗓️ Haftalık Plan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _DeliveryReminders(),
          const SizedBox(height: 20),
          const _TasksSection(),
        ],
      ),
    );
  }
}

class _DeliveryReminders extends ConsumerWidget {
  const _DeliveryReminders();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);

    List<Order> bucket(bool Function(int diff) test) {
      return orders.where((o) {
        if (o.status == OrderStatus.teslimEdildi) return false;
        final diff = DateTime(o.deliveryDate.year, o.deliveryDate.month,
                o.deliveryDate.day)
            .difference(mockToday)
            .inDays;
        return test(diff);
      }).toList();
    }

    final gecikenler = bucket((d) => d < 0);
    final bugun = bucket((d) => d == 0);
    final yarin = bucket((d) => d == 1);
    final buHafta = bucket((d) => d >= 2 && d <= 7);

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🚚 Teslimat Hatırlatıcısı',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _ReminderColumn(
                title: 'Geciken Teslimatlar',
                color: AppColors.danger,
                orders: gecikenler,
                noteBuilder: (o) {
                  final d = mockToday
                      .difference(DateTime(o.deliveryDate.year,
                          o.deliveryDate.month, o.deliveryDate.day))
                      .inDays;
                  return '$d gün geçti';
                },
                noteColor: AppColors.danger,
              ),
              _ReminderColumn(
                title: 'Bugün Teslim',
                color: AppColors.primary,
                orders: bugun,
                noteBuilder: (_) => 'Bugün',
                noteColor: AppColors.primary,
              ),
              _ReminderColumn(
                title: 'Yarın Teslim',
                color: const Color(0xFFC9A227),
                orders: yarin,
                noteBuilder: (_) => 'Yarın',
                noteColor: const Color(0xFFC9A227),
              ),
              _ReminderColumn(
                title: 'Bu Hafta',
                color: AppColors.info,
                orders: buHafta,
                noteBuilder: (o) {
                  final d = DateTime(o.deliveryDate.year, o.deliveryDate.month,
                          o.deliveryDate.day)
                      .difference(mockToday)
                      .inDays;
                  return '$d gün kaldı';
                },
                noteColor: AppColors.info,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReminderColumn extends StatelessWidget {
  const _ReminderColumn({
    required this.title,
    required this.color,
    required this.orders,
    required this.noteBuilder,
    required this.noteColor,
  });

  final String title;
  final Color color;
  final List<Order> orders;
  final String Function(Order) noteBuilder;
  final Color noteColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: color,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.white,
                  child: Text('${orders.length}',
                      style: TextStyle(
                          color: color, fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: orders.isEmpty
                ? const Text('Yok', style: TextStyle(color: AppColors.textMuted))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final o in orders) ...[
                        Text(o.customerName,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        Text('📞 ${o.phone}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        Text(o.address,
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        Text(noteBuilder(o),
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700, color: noteColor)),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _TasksSection extends ConsumerStatefulWidget {
  const _TasksSection();

  @override
  ConsumerState<_TasksSection> createState() => _TasksSectionState();
}

class _TasksSectionState extends ConsumerState<_TasksSection> {
  final _titleCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider);

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Görevler',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 260,
                child: TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(hintText: 'Hızlı hatırlatma ekle...'),
                ),
              ),
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _dateCtrl,
                  decoration: const InputDecoration(hintText: 'gg.aa.yyyy'),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_titleCtrl.text.trim().isEmpty) return;
                  ref.read(tasksProvider.notifier).addTask(_titleCtrl.text.trim(), null);
                  _titleCtrl.clear();
                  _dateCtrl.clear();
                },
                child: const Text('EKLE'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final t in tasks)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7E8),
                border: Border.all(color: const Color(0xFFF0D18A)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Text('⚠️ '),
                  Expanded(
                    child: Text(
                      t.title,
                      style: TextStyle(
                        decoration: t.done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    onPressed: () =>
                        ref.read(tasksProvider.notifier).toggleDone(t.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () =>
                        ref.read(tasksProvider.notifier).removeTask(t.id),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

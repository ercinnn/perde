import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/finance_models.dart';

class ReceivablesNotifier extends StateNotifier<List<Receivable>> {
  ReceivablesNotifier() : super(_seed());
  int _seq = 3;

  static List<Receivable> _seed() => [
        Receivable(
          id: 'rcv-1',
          customerName: 'Mustafa Aksoy',
          total: 4420,
          remaining: 420,
          dueDate: DateTime(2026, 7, 30),
        ),
        Receivable(
          id: 'rcv-2',
          customerName: 'Hasan Şahin',
          total: 2700,
          remaining: 1700,
          dueDate: DateTime(2026, 7, 28),
        ),
        Receivable(
          id: 'rcv-3',
          customerName: 'Ali Veli',
          total: 1350,
          remaining: 1350,
          dueDate: DateTime(2026, 8, 5),
        ),
      ];

  void addReceivable(Receivable r) => state = [...state, r];
  String nextId() {
    _seq += 1;
    return 'rcv-$_seq';
  }
}

final receivablesProvider =
    StateNotifierProvider<ReceivablesNotifier, List<Receivable>>(
        (ref) => ReceivablesNotifier());

class DebtsNotifier extends StateNotifier<List<Debt>> {
  DebtsNotifier() : super(_seed());
  int _seq = 3;

  static List<Debt> _seed() => [
        Debt(
          id: 'debt-1',
          supplierName: 'Fon Center',
          description: 'Blackout kumaş toplu alım',
          total: 3900,
          remaining: 3900,
          dueDate: DateTime(2026, 8, 10),
          status: PaymentStatus.bekliyor,
        ),
        Debt(
          id: 'debt-2',
          supplierName: 'Ray Sistemleri Ltd.',
          description: '20 adet ray siparişi',
          total: 4200,
          remaining: 0,
          dueDate: DateTime(2026, 7, 15),
          status: PaymentStatus.odendi,
        ),
        Debt(
          id: 'debt-3',
          supplierName: 'Aydınlı Tekstil',
          description: 'Temmuz ayı kumaş alımı',
          total: 6200,
          remaining: 3200,
          dueDate: DateTime(2026, 7, 31),
          status: PaymentStatus.bekliyor,
        ),
      ];

  void addDebt(Debt d) => state = [...state, d];
  String nextId() {
    _seq += 1;
    return 'debt-$_seq';
  }
}

final debtsProvider =
    StateNotifierProvider<DebtsNotifier, List<Debt>>((ref) => DebtsNotifier());

class InstallmentsNotifier extends StateNotifier<List<InstallmentPlan>> {
  InstallmentsNotifier() : super([]);
  int _seq = 0;
  void addPlan(InstallmentPlan p) => state = [...state, p];
  String nextId() {
    _seq += 1;
    return 'inst-$_seq';
  }
}

final installmentsProvider =
    StateNotifierProvider<InstallmentsNotifier, List<InstallmentPlan>>(
        (ref) => InstallmentsNotifier());

class RemindersNotifier extends StateNotifier<List<PaymentReminder>> {
  RemindersNotifier() : super([]);
  int _seq = 0;
  void addReminder(PaymentReminder r) => state = [...state, r];
  String nextId() {
    _seq += 1;
    return 'rem-$_seq';
  }
}

final remindersProvider =
    StateNotifierProvider<RemindersNotifier, List<PaymentReminder>>(
        (ref) => RemindersNotifier());

class CashRecordsNotifier extends StateNotifier<List<CashRecord>> {
  CashRecordsNotifier() : super(_seed());
  int _seq = 6;

  static List<CashRecord> _seed() {
    final d = DateTime(2026, 7, 14, 12, 28);
    return [
      CashRecord(
        id: 'cash-1',
        type: CashType.gelir,
        category: 'Elden Satis',
        amount: 3000,
        description: 'Ayşe Yılmaz - kapora',
        time: d,
      ),
      CashRecord(
        id: 'cash-2',
        type: CashType.gelir,
        category: 'Siparis Kaporasi',
        amount: 4000,
        description: 'Mustafa Aksoy (S260714-0011)',
        time: d,
      ),
      CashRecord(
        id: 'cash-3',
        type: CashType.gelir,
        category: 'Siparis Kaporasi',
        amount: 2500,
        description: 'Elif Çelik (S260714-0009)',
        time: d,
      ),
      CashRecord(
        id: 'cash-4',
        type: CashType.gelir,
        category: 'Siparis Kaporasi',
        amount: 1000,
        description: 'Hasan Şahin (S260714-0008)',
        time: d,
      ),
      CashRecord(
        id: 'cash-5',
        type: CashType.gelir,
        category: 'Siparis Kaporasi',
        amount: 8000,
        description: 'Zeynep Aydın (S260714-0007)',
        time: d,
      ),
      CashRecord(
        id: 'cash-6',
        type: CashType.gelir,
        category: 'Siparis Kaporasi',
        amount: 5000,
        description: 'Fatma Kaya (S260714-0004)',
        time: d,
      ),
    ];
  }

  void addRecord(CashRecord r) => state = [...state, r];
  void removeRecord(String id) => state = state.where((r) => r.id != id).toList();
  String nextId() {
    _seq += 1;
    return 'cash-$_seq';
  }

  double totalFor(CashType type, DateTime date) => state
      .where((r) =>
          r.type == type &&
          r.time.year == date.year &&
          r.time.month == date.month &&
          r.time.day == date.day)
      .fold(0, (s, r) => s + r.amount);
}

final cashRecordsProvider =
    StateNotifierProvider<CashRecordsNotifier, List<CashRecord>>(
        (ref) => CashRecordsNotifier());

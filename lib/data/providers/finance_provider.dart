import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/supabase/supabase_config.dart';
import '../models/enums.dart';
import '../models/finance_models.dart';

class ReceivablesNotifier extends StateNotifier<List<Receivable>> {
  ReceivablesNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final rows = await supabase.from('receivables').select().order('due_date');
    state = [for (final row in rows) Receivable.fromMap(row)];
  }

  String nextId() => 'rcv-tmp-${DateTime.now().microsecondsSinceEpoch}';

  Future<void> addReceivable(Receivable r) async {
    state = [...state, r];
    try {
      final row =
          await supabase.from('receivables').insert(r.toInsertMap()).select().single();
      final saved = Receivable.fromMap(row);
      state = [for (final x in state) if (x.id == r.id) saved else x];
    } catch (e) {
      state = [for (final x in state) if (x.id != r.id) x];
      debugPrint('addReceivable failed: $e');
      rethrow;
    }
  }
}

final receivablesProvider =
    StateNotifierProvider<ReceivablesNotifier, List<Receivable>>(
        (ref) => ReceivablesNotifier());

class DebtsNotifier extends StateNotifier<List<Debt>> {
  DebtsNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final rows = await supabase.from('debts').select().order('due_date');
    state = [for (final row in rows) Debt.fromMap(row)];
  }

  String nextId() => 'debt-tmp-${DateTime.now().microsecondsSinceEpoch}';

  Future<void> addDebt(Debt d) async {
    state = [...state, d];
    try {
      final row = await supabase.from('debts').insert(d.toInsertMap()).select().single();
      final saved = Debt.fromMap(row);
      state = [for (final x in state) if (x.id == d.id) saved else x];
    } catch (e) {
      state = [for (final x in state) if (x.id != d.id) x];
      debugPrint('addDebt failed: $e');
      rethrow;
    }
  }
}

final debtsProvider =
    StateNotifierProvider<DebtsNotifier, List<Debt>>((ref) => DebtsNotifier());

class InstallmentsNotifier extends StateNotifier<List<InstallmentPlan>> {
  InstallmentsNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final rows = await supabase.from('installment_plans').select().order('start_date');
    state = [for (final row in rows) InstallmentPlan.fromMap(row)];
  }

  String nextId() => 'inst-tmp-${DateTime.now().microsecondsSinceEpoch}';

  Future<void> addPlan(InstallmentPlan p) async {
    state = [...state, p];
    try {
      final row = await supabase
          .from('installment_plans')
          .insert(p.toInsertMap())
          .select()
          .single();
      final saved = InstallmentPlan.fromMap(row);
      state = [for (final x in state) if (x.id == p.id) saved else x];
    } catch (e) {
      state = [for (final x in state) if (x.id != p.id) x];
      debugPrint('addPlan failed: $e');
      rethrow;
    }
  }
}

final installmentsProvider =
    StateNotifierProvider<InstallmentsNotifier, List<InstallmentPlan>>(
        (ref) => InstallmentsNotifier());

class RemindersNotifier extends StateNotifier<List<PaymentReminder>> {
  RemindersNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final rows = await supabase.from('payment_reminders').select().order('due_date');
    state = [for (final row in rows) PaymentReminder.fromMap(row)];
  }

  String nextId() => 'rem-tmp-${DateTime.now().microsecondsSinceEpoch}';

  Future<void> addReminder(PaymentReminder r) async {
    state = [...state, r];
    try {
      final row = await supabase
          .from('payment_reminders')
          .insert(r.toInsertMap())
          .select()
          .single();
      final saved = PaymentReminder.fromMap(row);
      state = [for (final x in state) if (x.id == r.id) saved else x];
    } catch (e) {
      state = [for (final x in state) if (x.id != r.id) x];
      debugPrint('addReminder failed: $e');
      rethrow;
    }
  }
}

final remindersProvider =
    StateNotifierProvider<RemindersNotifier, List<PaymentReminder>>(
        (ref) => RemindersNotifier());

class CashRecordsNotifier extends StateNotifier<List<CashRecord>> {
  CashRecordsNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final rows = await supabase.from('cash_records').select().order('time');
    state = [for (final row in rows) CashRecord.fromMap(row)];
  }

  String nextId() => 'cash-tmp-${DateTime.now().microsecondsSinceEpoch}';

  Future<void> addRecord(CashRecord r) async {
    state = [...state, r];
    try {
      final row =
          await supabase.from('cash_records').insert(r.toInsertMap()).select().single();
      final saved = CashRecord.fromMap(row);
      state = [for (final x in state) if (x.id == r.id) saved else x];
    } catch (e) {
      state = [for (final x in state) if (x.id != r.id) x];
      debugPrint('addRecord failed: $e');
      rethrow;
    }
  }

  Future<void> removeRecord(String id) async {
    final previous = state;
    state = state.where((r) => r.id != id).toList();
    try {
      await supabase.from('cash_records').delete().eq('id', id);
    } catch (e) {
      state = previous;
      debugPrint('removeRecord failed: $e');
      rethrow;
    }
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

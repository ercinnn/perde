import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/supabase/supabase_config.dart';
import '../models/planning_models.dart';

class WeeklyPlanNotifier extends StateNotifier<List<WeeklyPlanEntry>> {
  WeeklyPlanNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final rows = await supabase.from('weekly_plan_entries').select().order('date');
    state = [for (final row in rows) WeeklyPlanEntry.fromMap(row)];
  }

  String nextId() => 'plan-tmp-${DateTime.now().microsecondsSinceEpoch}';

  Future<void> addEntry(WeeklyPlanEntry e) async {
    state = [...state, e];
    try {
      final row = await supabase
          .from('weekly_plan_entries')
          .insert(e.toInsertMap())
          .select()
          .single();
      final saved = WeeklyPlanEntry.fromMap(row);
      state = [for (final x in state) if (x.id == e.id) saved else x];
    } catch (err) {
      state = [for (final x in state) if (x.id != e.id) x];
      debugPrint('addEntry failed: $err');
      rethrow;
    }
  }
}

final weeklyPlanProvider =
    StateNotifierProvider<WeeklyPlanNotifier, List<WeeklyPlanEntry>>(
        (ref) => WeeklyPlanNotifier());

class PileFeesNotifier extends StateNotifier<List<PileFee>> {
  PileFeesNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final rows = await supabase.from('pile_fees').select().order('name');
    state = [for (final row in rows) PileFee.fromMap(row)];
  }

  String nextId() => 'pf-tmp-${DateTime.now().microsecondsSinceEpoch}';

  Future<void> addFee(PileFee f) async {
    state = [...state, f];
    try {
      final row = await supabase.from('pile_fees').insert(f.toInsertMap()).select().single();
      final saved = PileFee.fromMap(row);
      state = [for (final x in state) if (x.id == f.id) saved else x];
    } catch (e) {
      state = [for (final x in state) if (x.id != f.id) x];
      debugPrint('addFee failed: $e');
      rethrow;
    }
  }

  Future<void> removeFee(String id) async {
    final previous = state;
    state = state.where((f) => f.id != id).toList();
    try {
      await supabase.from('pile_fees').delete().eq('id', id);
    } catch (e) {
      state = previous;
      debugPrint('removeFee failed: $e');
      rethrow;
    }
  }
}

final pileFeesProvider =
    StateNotifierProvider<PileFeesNotifier, List<PileFee>>(
        (ref) => PileFeesNotifier());

class FeaturePricesNotifier extends StateNotifier<List<ProductFeaturePrice>> {
  FeaturePricesNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final rows = await supabase.from('product_feature_prices').select().order('option_name');
    state = [for (final row in rows) ProductFeaturePrice.fromMap(row)];
  }

  String nextId() => 'fp-tmp-${DateTime.now().microsecondsSinceEpoch}';

  Future<void> addFeature(ProductFeaturePrice f) async {
    state = [...state, f];
    try {
      final row = await supabase
          .from('product_feature_prices')
          .insert(f.toInsertMap())
          .select()
          .single();
      final saved = ProductFeaturePrice.fromMap(row);
      state = [for (final x in state) if (x.id == f.id) saved else x];
    } catch (e) {
      state = [for (final x in state) if (x.id != f.id) x];
      debugPrint('addFeature failed: $e');
      rethrow;
    }
  }

  Future<void> removeFeature(String id) async {
    final previous = state;
    state = state.where((f) => f.id != id).toList();
    try {
      await supabase.from('product_feature_prices').delete().eq('id', id);
    } catch (e) {
      state = previous;
      debugPrint('removeFeature failed: $e');
      rethrow;
    }
  }
}

final featurePricesProvider =
    StateNotifierProvider<FeaturePricesNotifier, List<ProductFeaturePrice>>(
        (ref) => FeaturePricesNotifier());

class TasksNotifier extends StateNotifier<List<TaskReminder>> {
  TasksNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final rows = await supabase.from('task_reminders').select().order('title');
    state = [for (final row in rows) TaskReminder.fromMap(row)];
  }

  Future<void> addTask(String title, DateTime? dueDate) async {
    final optimistic = TaskReminder(
      id: 'task-tmp-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      dueDate: dueDate,
    );
    state = [...state, optimistic];
    try {
      final row = await supabase
          .from('task_reminders')
          .insert(optimistic.toInsertMap())
          .select()
          .single();
      final saved = TaskReminder.fromMap(row);
      state = [for (final x in state) if (x.id == optimistic.id) saved else x];
    } catch (e) {
      state = [for (final x in state) if (x.id != optimistic.id) x];
      debugPrint('addTask failed: $e');
      rethrow;
    }
  }

  Future<void> toggleDone(String id) async {
    final previous = state;
    state = [
      for (final t in state) if (t.id == id) t.copyWith(done: !t.done) else t,
    ];
    final updated = state.firstWhere((t) => t.id == id);
    try {
      await supabase.from('task_reminders').update({'done': updated.done}).eq('id', id);
    } catch (e) {
      state = previous;
      debugPrint('toggleDone failed: $e');
      rethrow;
    }
  }

  Future<void> removeTask(String id) async {
    final previous = state;
    state = state.where((t) => t.id != id).toList();
    try {
      await supabase.from('task_reminders').delete().eq('id', id);
    } catch (e) {
      state = previous;
      debugPrint('removeTask failed: $e');
      rethrow;
    }
  }
}

final tasksProvider =
    StateNotifierProvider<TasksNotifier, List<TaskReminder>>(
        (ref) => TasksNotifier());

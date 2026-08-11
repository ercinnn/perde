import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/planning_models.dart';

class WeeklyPlanNotifier extends StateNotifier<List<WeeklyPlanEntry>> {
  WeeklyPlanNotifier() : super(_seed());
  int _seq = 3;

  static List<WeeklyPlanEntry> _seed() => [
        WeeklyPlanEntry(
          id: 'plan-1',
          date: DateTime(2026, 7, 15),
          time: '10.30',
          customerName: 'Fatma Kaya',
          description: 'Salon fon+tül montajı',
        ),
        WeeklyPlanEntry(
          id: 'plan-2',
          date: DateTime(2026, 7, 16),
          time: '14.00',
          customerName: 'Ayşe Yılmaz',
          description: 'Salon montajı',
        ),
        WeeklyPlanEntry(
          id: 'plan-3',
          date: DateTime(2026, 7, 18),
          time: '09.30',
          customerName: 'Mustafa Aksoy',
          description: 'Salon tül montajı - Yıldırım bölgesi',
        ),
      ];

  void addEntry(WeeklyPlanEntry e) => state = [...state, e];
  String nextId() {
    _seq += 1;
    return 'plan-$_seq';
  }
}

final weeklyPlanProvider =
    StateNotifierProvider<WeeklyPlanNotifier, List<WeeklyPlanEntry>>(
        (ref) => WeeklyPlanNotifier());

class PileFeesNotifier extends StateNotifier<List<PileFee>> {
  PileFeesNotifier() : super(_seed());
  int _seq = 8;

  static List<PileFee> _seed() => [
        PileFee(id: 'pf-1', name: 'Ağ Pile', price: 45),
        PileFee(id: 'pf-2', name: 'Yan Pile', price: 55),
        PileFee(id: 'pf-3', name: 'S Pile', price: 50),
        PileFee(id: 'pf-4', name: 'V Pile', price: 60),
        PileFee(id: 'pf-5', name: 'Düz Pile', price: 40),
        PileFee(id: 'pf-6', name: 'Kelebek Pile', price: 70),
        PileFee(id: 'pf-7', name: 'Göbek Pile', price: 65),
        PileFee(id: 'pf-8', name: 'Kruvaze Fon', price: 150),
      ];

  void addFee(PileFee f) => state = [...state, f];
  void removeFee(String id) => state = state.where((f) => f.id != id).toList();
  String nextId() {
    _seq += 1;
    return 'pf-$_seq';
  }
}

final pileFeesProvider =
    StateNotifierProvider<PileFeesNotifier, List<PileFee>>(
        (ref) => PileFeesNotifier());

class FeaturePricesNotifier extends StateNotifier<List<ProductFeaturePrice>> {
  FeaturePricesNotifier() : super(_seed());
  int _seq = 4;

  static List<ProductFeaturePrice> _seed() => [
        ProductFeaturePrice(
          id: 'fp-1',
          productType: ProductType.pliseli,
          optionName: 'Yapıştırmalı',
          price: 150,
        ),
        ProductFeaturePrice(
          id: 'fp-2',
          productType: ProductType.ahsapJaluzi,
          optionName: 'Kurdelasız + Redüktörsüz',
          price: -300,
        ),
        ProductFeaturePrice(
          id: 'fp-3',
          productType: ProductType.stor,
          optionName: 'Motorlu Sistem',
          price: 1200,
        ),
        ProductFeaturePrice(
          id: 'fp-4',
          productType: ProductType.zebra,
          optionName: 'Motorlu Sistem',
          price: 1200,
        ),
      ];

  void addFeature(ProductFeaturePrice f) => state = [...state, f];
  void removeFeature(String id) =>
      state = state.where((f) => f.id != id).toList();
  String nextId() {
    _seq += 1;
    return 'fp-$_seq';
  }
}

final featurePricesProvider =
    StateNotifierProvider<FeaturePricesNotifier, List<ProductFeaturePrice>>(
        (ref) => FeaturePricesNotifier());

class TasksNotifier extends StateNotifier<List<TaskReminder>> {
  TasksNotifier() : super(_seed());
  int _seq = 1;

  static List<TaskReminder> _seed() => [
        TaskReminder(
          id: 'task-1',
          title: 'Blackout Fon Kumaş - Krem — 30 metre',
        ),
      ];

  void addTask(String title, DateTime? dueDate) {
    _seq += 1;
    state = [
      ...state,
      TaskReminder(id: 'task-$_seq', title: title, dueDate: dueDate),
    ];
  }

  void toggleDone(String id) {
    state = [
      for (final t in state) if (t.id == id) t.copyWith(done: !t.done) else t,
    ];
  }

  void removeTask(String id) => state = state.where((t) => t.id != id).toList();
}

final tasksProvider =
    StateNotifierProvider<TasksNotifier, List<TaskReminder>>(
        (ref) => TasksNotifier());

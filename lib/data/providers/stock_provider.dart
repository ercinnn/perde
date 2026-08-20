import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/supabase/supabase_config.dart';
import '../models/stock_models.dart';

class StockNotifier extends StateNotifier<List<StockItem>> {
  StockNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final rows = await supabase.from('stock_items').select().order('name');
    state = [for (final row in rows) StockItem.fromMap(row)];
  }

  String nextId() => 'stk-tmp-${DateTime.now().microsecondsSinceEpoch}';

  Future<void> addItem(StockItem item) async {
    state = [...state, item];
    try {
      final row =
          await supabase.from('stock_items').insert(item.toInsertMap()).select().single();
      final saved = StockItem.fromMap(row);
      state = [for (final s in state) if (s.id == item.id) saved else s];
    } catch (e) {
      state = [for (final s in state) if (s.id != item.id) s];
      debugPrint('addItem failed: $e');
      rethrow;
    }
  }

  Future<void> adjustQuantity(String id, double delta) async {
    final previous = state;
    StockItem? changed;
    state = [
      for (final s in state)
        if (s.id == id) (changed = s.copyWith(quantity: s.quantity + delta)) else s,
    ];
    if (changed == null) return;
    try {
      await supabase.from('stock_items').update({
        'quantity': changed.quantity,
        'last_updated': changed.lastUpdated.toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      state = previous;
      debugPrint('adjustQuantity failed: $e');
      rethrow;
    }
  }

  Future<void> removeItem(String id) async {
    final previous = state;
    state = state.where((s) => s.id != id).toList();
    try {
      await supabase.from('stock_items').delete().eq('id', id);
    } catch (e) {
      state = previous;
      debugPrint('removeItem failed: $e');
      rethrow;
    }
  }
}

final stockProvider =
    StateNotifierProvider<StockNotifier, List<StockItem>>((ref) => StockNotifier());

class SuppliersNotifier extends StateNotifier<List<Supplier>> {
  SuppliersNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final rows = await supabase.from('suppliers').select().order('name');
    state = [for (final row in rows) Supplier.fromMap(row)];
  }

  String nextId() => 'sup-tmp-${DateTime.now().microsecondsSinceEpoch}';

  Future<void> addSupplier(Supplier supplier) async {
    state = [...state, supplier];
    try {
      final row =
          await supabase.from('suppliers').insert(supplier.toInsertMap()).select().single();
      final saved = Supplier.fromMap(row);
      state = [for (final s in state) if (s.id == supplier.id) saved else s];
    } catch (e) {
      state = [for (final s in state) if (s.id != supplier.id) s];
      debugPrint('addSupplier failed: $e');
      rethrow;
    }
  }

  Future<void> removeSupplier(String id) async {
    final previous = state;
    state = state.where((s) => s.id != id).toList();
    try {
      await supabase.from('suppliers').delete().eq('id', id);
    } catch (e) {
      state = previous;
      debugPrint('removeSupplier failed: $e');
      rethrow;
    }
  }

  Future<void> addProductToSupplier(String supplierId, SupplierProduct product) async {
    final previous = state;
    Supplier? updated;
    state = [
      for (final s in state)
        if (s.id == supplierId)
          (updated = Supplier(
            id: s.id,
            name: s.name,
            contactPerson: s.contactPerson,
            phone: s.phone,
            email: s.email,
            category: s.category,
            address: s.address,
            notes: s.notes,
            products: [...s.products, product],
          ))
        else
          s,
    ];
    if (updated == null) return;
    try {
      await supabase
          .from('suppliers')
          .update({'products': updated.products.map((p) => p.toMap()).toList()})
          .eq('id', supplierId);
    } catch (e) {
      state = previous;
      debugPrint('addProductToSupplier failed: $e');
      rethrow;
    }
  }
}

final suppliersProvider =
    StateNotifierProvider<SuppliersNotifier, List<Supplier>>(
        (ref) => SuppliersNotifier());

class StockRequestsNotifier extends StateNotifier<List<StockRequest>> {
  StockRequestsNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final rows = await supabase.from('stock_requests').select().order('delivery_date');
    state = [for (final row in rows) StockRequest.fromMap(row)];
  }

  String nextId() => 'req-tmp-${DateTime.now().microsecondsSinceEpoch}';

  Future<void> addRequest(StockRequest r) async {
    state = [...state, r];
    try {
      final row =
          await supabase.from('stock_requests').insert(r.toInsertMap()).select().single();
      final saved = StockRequest.fromMap(row);
      state = [for (final x in state) if (x.id == r.id) saved else x];
    } catch (e) {
      state = [for (final x in state) if (x.id != r.id) x];
      debugPrint('addRequest failed: $e');
      rethrow;
    }
  }

  Future<void> removeRequest(String id) async {
    final previous = state;
    state = state.where((r) => r.id != id).toList();
    try {
      await supabase.from('stock_requests').delete().eq('id', id);
    } catch (e) {
      state = previous;
      debugPrint('removeRequest failed: $e');
      rethrow;
    }
  }
}

final stockRequestsProvider =
    StateNotifierProvider<StockRequestsNotifier, List<StockRequest>>(
        (ref) => StockRequestsNotifier());

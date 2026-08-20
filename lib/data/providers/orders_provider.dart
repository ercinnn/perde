import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/supabase/supabase_config.dart';
import '../../core/utils/mock_clock.dart';
import '../models/enums.dart';
import '../models/order_models.dart';

class OrdersNotifier extends StateNotifier<List<Order>> {
  OrdersNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final rows = await supabase
        .from('orders')
        .select()
        .order('order_date', ascending: false);
    state = [for (final row in rows) Order.fromMap(row)];
  }

  String nextCode() {
    final prefix = 'S${_yymmdd(mockToday)}-';
    var maxSeq = 0;
    for (final o in state) {
      if (o.code.startsWith(prefix)) {
        final n = int.tryParse(o.code.substring(prefix.length));
        if (n != null && n > maxSeq) maxSeq = n;
      }
    }
    return '$prefix${(maxSeq + 1).toString().padLeft(4, '0')}';
  }

  static String _yymmdd(DateTime d) {
    final yy = (d.year % 100).toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$yy$mm$dd';
  }

  Future<void> addOrder(Order order) async {
    state = [...state, order];
    try {
      final row =
          await supabase.from('orders').insert(order.toInsertMap()).select().single();
      final saved = Order.fromMap(row);
      state = [for (final o in state) if (o.id == order.id) saved else o];
    } catch (e) {
      state = [for (final o in state) if (o.id != order.id) o];
      debugPrint('addOrder failed: $e');
      rethrow;
    }
  }

  Future<void> updateOrder(Order order) async {
    final previous = state;
    state = [
      for (final o in state) if (o.id == order.id) order else o,
    ];
    try {
      await supabase.from('orders').update(order.toInsertMap()).eq('id', order.id);
    } catch (e) {
      state = previous;
      debugPrint('updateOrder failed: $e');
      rethrow;
    }
  }

  Future<void> setStatus(String orderId, OrderStatus status) async {
    final previous = state;
    state = [
      for (final o in state)
        if (o.id == orderId) o.copyWith(status: status) else o,
    ];
    try {
      await supabase.from('orders').update({'status': status.name}).eq('id', orderId);
    } catch (e) {
      state = previous;
      debugPrint('setStatus failed: $e');
      rethrow;
    }
  }
}

final ordersProvider =
    StateNotifierProvider<OrdersNotifier, List<Order>>((ref) => OrdersNotifier());

final customersProvider = Provider<List<CustomerSummary>>((ref) {
  final orders = ref.watch(ordersProvider);
  final byPhone = <String, List<Order>>{};
  for (final o in orders) {
    byPhone.putIfAbsent(o.phone, () => []).add(o);
  }
  return byPhone.values
      .map((orders) => CustomerSummary(
            name: orders.first.customerName,
            phone: orders.first.phone,
            address: orders.first.address,
            orders: orders,
          ))
      .toList();
});

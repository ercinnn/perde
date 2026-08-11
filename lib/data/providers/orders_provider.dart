import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/order_models.dart';

class OrdersNotifier extends StateNotifier<List<Order>> {
  OrdersNotifier() : super(_seed());
  int _seq = 12;

  static List<Order> _seed() {
    final today = DateTime(2026, 7, 14);
    Order mk(
      int i,
      String name,
      String phone,
      String address,
      DateTime delivery,
      OrderStatus status,
      double total,
      double deposit,
    ) {
      final code =
          'S260714-${(i).toString().padLeft(4, '0')}';
      return Order(
        id: 'ord-$i',
        code: code,
        customerName: name,
        phone: phone,
        address: address,
        orderDate: today,
        deliveryDate: delivery,
        status: status,
        deposit: deposit,
        items: [
          OrderItem(
            id: 'ord-$i-item-1',
            productType: ProductType.stor,
            room: RoomType.salon,
            width: 1.5,
            height: 2.2,
            unitPrice: total,
            total: total,
          ),
        ],
      );
    }

    return [
      mk(1, 'Ali Veli', '05412345566', 'Yeşilyurt Mah. Gül Sok. No:3 Muratpaşa',
          DateTime(2026, 7, 25), OrderStatus.bekliyor, 1350, 0),
      mk(2, 'Ayşe Yılmaz', '05323456789', 'Bağdat Cad. No:45 Kadıköy',
          DateTime(2026, 7, 20), OrderStatus.bekliyor, 3000, 3000),
      mk(3, 'Elif Çelik', '05467891122', 'Barış Mah. Menekşe Sok. No:14 Osmangazi',
          DateTime(2026, 7, 15), OrderStatus.bekliyor, 2500, 2500),
      mk(4, 'Fatma Kaya', '05389876543', 'Cumhuriyet Cad. No:112 Çankaya',
          DateTime(2026, 7, 18), OrderStatus.bekliyor, 5000, 5000),
      mk(5, 'Hasan Şahin', '05421239900', 'İnönü Cad. No:67 Kepez',
          DateTime(2026, 7, 28), OrderStatus.bekliyor, 2700, 1000),
      mk(6, 'Mehmet Demir', '05451237788', 'Atatürk Mah. 12. Sok. No:8 Bornova',
          DateTime(2026, 7, 22), OrderStatus.bekliyor, 1800, 0),
      mk(7, 'Mustafa Aksoy', '05398887766', 'Gazi Mah. Lale Sok. No:9 Yıldırım',
          DateTime(2026, 7, 30), OrderStatus.bekliyor, 4420, 4000),
      mk(8, 'Zeynep Aydın', '05336547788', 'Fevzi Çakmak Mah. 5. Cad. No:22 Nilüfer',
          DateTime(2026, 7, 12), OrderStatus.bekliyor, 8000, 8000),
    ];
  }

  String nextCode() {
    _seq += 1;
    return 'S260714-${_seq.toString().padLeft(4, '0')}';
  }

  void addOrder(Order order) {
    state = [...state, order];
  }

  void updateOrder(Order order) {
    state = [
      for (final o in state) if (o.id == order.id) order else o,
    ];
  }

  void setStatus(String orderId, OrderStatus status) {
    state = [
      for (final o in state)
        if (o.id == orderId) o.copyWith(status: status) else o,
    ];
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

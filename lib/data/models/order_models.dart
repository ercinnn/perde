import 'enums.dart';

class OrderItem {
  OrderItem({
    required this.id,
    required this.productType,
    required this.room,
    this.productCode = '',
    required this.width,
    required this.height,
    this.pileType,
    this.pilePercent = 0,
    required this.unitPrice,
    this.quantity = 1,
    this.note = '',
    required this.total,
  });

  final String id;
  final ProductType productType;
  final RoomType room;
  final String productCode;
  final double width;
  final double height;
  final String? pileType;
  final double pilePercent;
  final double unitPrice;
  final int quantity;
  final String note;
  final double total;
}

class Order {
  Order({
    required this.id,
    required this.code,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.orderDate,
    required this.deliveryDate,
    this.deliveryType = DeliveryType.montaj,
    this.planTime = '09.00',
    List<OrderItem>? items,
    this.deposit = 0,
    this.discount = 0,
    this.status = OrderStatus.bekliyor,
  }) : items = items ?? [];

  final String id;
  final String code;
  final String customerName;
  final String phone;
  final String address;
  final DateTime orderDate;
  final DateTime deliveryDate;
  final DeliveryType deliveryType;
  final String planTime;
  final List<OrderItem> items;
  final double deposit;
  final double discount;
  final OrderStatus status;

  double get subtotal => items.fold(0, (sum, i) => sum + i.total);
  double get grandTotal => (subtotal - discount).clamp(0, double.infinity);
  double get remaining => (grandTotal - deposit).clamp(0, double.infinity);

  Order copyWith({
    List<OrderItem>? items,
    double? deposit,
    double? discount,
    OrderStatus? status,
  }) {
    return Order(
      id: id,
      code: code,
      customerName: customerName,
      phone: phone,
      address: address,
      orderDate: orderDate,
      deliveryDate: deliveryDate,
      deliveryType: deliveryType,
      planTime: planTime,
      items: items ?? this.items,
      deposit: deposit ?? this.deposit,
      discount: discount ?? this.discount,
      status: status ?? this.status,
    );
  }
}

class CustomerSummary {
  CustomerSummary({
    required this.name,
    required this.phone,
    required this.address,
    required this.orders,
  });

  final String name;
  final String phone;
  final String address;
  final List<Order> orders;

  Order get latestOrder =>
      orders.reduce((a, b) => a.orderDate.isAfter(b.orderDate) ? a : b);

  double get totalAmount => orders.fold(0, (s, o) => s + o.grandTotal);
  double get totalDeposit => orders.fold(0, (s, o) => s + o.deposit);
  double get totalRemaining => orders.fold(0, (s, o) => s + o.remaining);
}

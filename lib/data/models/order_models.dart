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

  Map<String, dynamic> toMap() => {
        'id': id,
        'product_type': productType.name,
        'room': room.name,
        'product_code': productCode,
        'width': width,
        'height': height,
        'pile_type': pileType,
        'pile_percent': pilePercent,
        'unit_price': unitPrice,
        'quantity': quantity,
        'note': note,
        'total': total,
      };

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
        id: map['id'] as String,
        productType: ProductType.values.byName(map['product_type'] as String),
        room: RoomType.values.byName(map['room'] as String),
        productCode: map['product_code'] as String? ?? '',
        width: (map['width'] as num).toDouble(),
        height: (map['height'] as num).toDouble(),
        pileType: map['pile_type'] as String?,
        pilePercent: (map['pile_percent'] as num?)?.toDouble() ?? 0,
        unitPrice: (map['unit_price'] as num).toDouble(),
        quantity: (map['quantity'] as num?)?.toInt() ?? 1,
        note: map['note'] as String? ?? '',
        total: (map['total'] as num).toDouble(),
      );
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

  Map<String, dynamic> toInsertMap() => {
        'code': code,
        'customer_name': customerName,
        'phone': phone,
        'address': address,
        'order_date': orderDate.toIso8601String(),
        'delivery_date': deliveryDate.toIso8601String(),
        'delivery_type': deliveryType.name,
        'plan_time': planTime,
        'items': items.map((i) => i.toMap()).toList(),
        'deposit': deposit,
        'discount': discount,
        'status': status.name,
      };

  factory Order.fromMap(Map<String, dynamic> map) => Order(
        id: map['id'] as String,
        code: map['code'] as String,
        customerName: map['customer_name'] as String,
        phone: map['phone'] as String,
        address: map['address'] as String,
        orderDate: DateTime.parse(map['order_date'] as String),
        deliveryDate: DateTime.parse(map['delivery_date'] as String),
        deliveryType: DeliveryType.values.byName(map['delivery_type'] as String),
        planTime: map['plan_time'] as String,
        items: (map['items'] as List<dynamic>? ?? [])
            .map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
            .toList(),
        deposit: (map['deposit'] as num).toDouble(),
        discount: (map['discount'] as num).toDouble(),
        status: OrderStatus.values.byName(map['status'] as String),
      );
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

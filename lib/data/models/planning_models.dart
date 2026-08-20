import 'enums.dart';

class WeeklyPlanEntry {
  WeeklyPlanEntry({
    required this.id,
    required this.date,
    required this.time,
    required this.customerName,
    required this.description,
    this.type = DeliveryType.montaj,
  });

  final String id;
  final DateTime date;
  final String time;
  final String customerName;
  final String description;
  final DeliveryType type;

  Map<String, dynamic> toInsertMap() => {
        'date': date.toIso8601String(),
        'time': time,
        'customer_name': customerName,
        'description': description,
        'type': type.name,
      };

  factory WeeklyPlanEntry.fromMap(Map<String, dynamic> map) => WeeklyPlanEntry(
        id: map['id'] as String,
        date: DateTime.parse(map['date'] as String),
        time: map['time'] as String? ?? '',
        customerName: map['customer_name'] as String,
        description: map['description'] as String? ?? '',
        type: DeliveryType.values.byName(map['type'] as String),
      );
}

class PileFee {
  PileFee({required this.id, required this.name, required this.price});
  final String id;
  final String name;
  final double price;

  Map<String, dynamic> toInsertMap() => {'name': name, 'price': price};

  factory PileFee.fromMap(Map<String, dynamic> map) => PileFee(
        id: map['id'] as String,
        name: map['name'] as String,
        price: (map['price'] as num).toDouble(),
      );
}

class ProductFeaturePrice {
  ProductFeaturePrice({
    required this.id,
    required this.productType,
    required this.optionName,
    required this.price,
    this.calcType = FeatureCalcType.sabit,
  });

  final String id;
  final ProductType productType;
  final String optionName;
  final double price;
  final FeatureCalcType calcType;

  Map<String, dynamic> toInsertMap() => {
        'product_type': productType.name,
        'option_name': optionName,
        'price': price,
        'calc_type': calcType.name,
      };

  factory ProductFeaturePrice.fromMap(Map<String, dynamic> map) => ProductFeaturePrice(
        id: map['id'] as String,
        productType: ProductType.values.byName(map['product_type'] as String),
        optionName: map['option_name'] as String,
        price: (map['price'] as num).toDouble(),
        calcType: FeatureCalcType.values.byName(map['calc_type'] as String),
      );
}

class TaskReminder {
  TaskReminder({
    required this.id,
    required this.title,
    this.dueDate,
    this.done = false,
  });

  final String id;
  final String title;
  final DateTime? dueDate;
  final bool done;

  TaskReminder copyWith({bool? done}) => TaskReminder(
        id: id,
        title: title,
        dueDate: dueDate,
        done: done ?? this.done,
      );

  Map<String, dynamic> toInsertMap() => {
        'title': title,
        'due_date': dueDate?.toIso8601String(),
        'done': done,
      };

  factory TaskReminder.fromMap(Map<String, dynamic> map) => TaskReminder(
        id: map['id'] as String,
        title: map['title'] as String,
        dueDate: map['due_date'] == null ? null : DateTime.parse(map['due_date'] as String),
        done: map['done'] as bool? ?? false,
      );
}

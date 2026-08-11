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
}

class PileFee {
  PileFee({required this.id, required this.name, required this.price});
  final String id;
  final String name;
  final double price;
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
}

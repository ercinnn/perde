import 'enums.dart';

class Receivable {
  Receivable({
    required this.id,
    required this.customerName,
    required this.total,
    required this.remaining,
    required this.dueDate,
    this.status = PaymentStatus.bekliyor,
  });

  final String id;
  final String customerName;
  final double total;
  final double remaining;
  final DateTime dueDate;
  final PaymentStatus status;
}

class Debt {
  Debt({
    required this.id,
    required this.supplierName,
    this.description = '',
    required this.total,
    required this.remaining,
    required this.dueDate,
    this.status = PaymentStatus.bekliyor,
  });

  final String id;
  final String supplierName;
  final String description;
  final double total;
  final double remaining;
  final DateTime dueDate;
  final PaymentStatus status;
}

class InstallmentPlan {
  InstallmentPlan({
    required this.id,
    required this.customerName,
    required this.totalAmount,
    required this.installmentCount,
    required this.startDate,
  });

  final String id;
  final String customerName;
  final double totalAmount;
  final int installmentCount;
  final DateTime startDate;
}

class PaymentReminder {
  PaymentReminder({
    required this.id,
    required this.title,
    required this.dueDate,
    this.note = '',
  });

  final String id;
  final String title;
  final DateTime dueDate;
  final String note;
}

class CashRecord {
  CashRecord({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    this.description = '',
    required this.time,
  });

  final String id;
  final CashType type;
  final String category;
  final double amount;
  final String description;
  final DateTime time;
}

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

  Map<String, dynamic> toInsertMap() => {
        'customer_name': customerName,
        'total': total,
        'remaining': remaining,
        'due_date': dueDate.toIso8601String(),
        'status': status.name,
      };

  factory Receivable.fromMap(Map<String, dynamic> map) => Receivable(
        id: map['id'] as String,
        customerName: map['customer_name'] as String,
        total: (map['total'] as num).toDouble(),
        remaining: (map['remaining'] as num).toDouble(),
        dueDate: DateTime.parse(map['due_date'] as String),
        status: PaymentStatus.values.byName(map['status'] as String),
      );
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

  Map<String, dynamic> toInsertMap() => {
        'supplier_name': supplierName,
        'description': description,
        'total': total,
        'remaining': remaining,
        'due_date': dueDate.toIso8601String(),
        'status': status.name,
      };

  factory Debt.fromMap(Map<String, dynamic> map) => Debt(
        id: map['id'] as String,
        supplierName: map['supplier_name'] as String,
        description: map['description'] as String? ?? '',
        total: (map['total'] as num).toDouble(),
        remaining: (map['remaining'] as num).toDouble(),
        dueDate: DateTime.parse(map['due_date'] as String),
        status: PaymentStatus.values.byName(map['status'] as String),
      );
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

  Map<String, dynamic> toInsertMap() => {
        'customer_name': customerName,
        'total_amount': totalAmount,
        'installment_count': installmentCount,
        'start_date': startDate.toIso8601String(),
      };

  factory InstallmentPlan.fromMap(Map<String, dynamic> map) => InstallmentPlan(
        id: map['id'] as String,
        customerName: map['customer_name'] as String,
        totalAmount: (map['total_amount'] as num).toDouble(),
        installmentCount: (map['installment_count'] as num).toInt(),
        startDate: DateTime.parse(map['start_date'] as String),
      );
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

  Map<String, dynamic> toInsertMap() => {
        'title': title,
        'due_date': dueDate.toIso8601String(),
        'note': note,
      };

  factory PaymentReminder.fromMap(Map<String, dynamic> map) => PaymentReminder(
        id: map['id'] as String,
        title: map['title'] as String,
        dueDate: DateTime.parse(map['due_date'] as String),
        note: map['note'] as String? ?? '',
      );
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

  Map<String, dynamic> toInsertMap() => {
        'type': type.name,
        'category': category,
        'amount': amount,
        'description': description,
        'time': time.toIso8601String(),
      };

  factory CashRecord.fromMap(Map<String, dynamic> map) => CashRecord(
        id: map['id'] as String,
        type: CashType.values.byName(map['type'] as String),
        category: map['category'] as String? ?? '',
        amount: (map['amount'] as num).toDouble(),
        description: map['description'] as String? ?? '',
        time: DateTime.parse(map['time'] as String),
      );
}

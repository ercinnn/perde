class StockItem {
  StockItem({
    required this.id,
    required this.code,
    required this.name,
    this.brand = '',
    this.category = '',
    required this.quantity,
    this.unit = 'metre',
    required this.minStock,
    this.supplierName = '',
    this.purchasePrice = 0,
    this.description = '',
    required this.lastUpdated,
  });

  final String id;
  final String code;
  final String name;
  final String brand;
  final String category;
  final double quantity;
  final String unit;
  final double minStock;
  final String supplierName;
  final double purchasePrice;
  final String description;
  final DateTime lastUpdated;

  bool get isCritical => quantity < minStock;

  StockItem copyWith({double? quantity}) => StockItem(
        id: id,
        code: code,
        name: name,
        brand: brand,
        category: category,
        quantity: quantity ?? this.quantity,
        unit: unit,
        minStock: minStock,
        supplierName: supplierName,
        purchasePrice: purchasePrice,
        description: description,
        lastUpdated: DateTime.now(),
      );
}

class SupplierProduct {
  SupplierProduct({required this.name, required this.price, this.unit = 'metre'});
  final String name;
  final double price;
  final String unit;
}

class Supplier {
  Supplier({
    required this.id,
    required this.name,
    this.contactPerson = '',
    this.phone = '',
    this.email = '',
    this.category = '',
    this.address = '',
    this.notes = '',
    List<SupplierProduct>? products,
  }) : products = products ?? [];

  final String id;
  final String name;
  final String contactPerson;
  final String phone;
  final String email;
  final String category;
  final String address;
  final String notes;
  final List<SupplierProduct> products;
}

class StockRequest {
  StockRequest({
    required this.id,
    required this.supplierName,
    required this.productName,
    required this.quantity,
    this.unit = 'metre',
    required this.deliveryDate,
    this.notes = '',
  });

  final String id;
  final String supplierName;
  final String productName;
  final double quantity;
  final String unit;
  final DateTime deliveryDate;
  final String notes;
}

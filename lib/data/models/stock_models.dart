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

  Map<String, dynamic> toInsertMap() => {
        'code': code,
        'name': name,
        'brand': brand,
        'category': category,
        'quantity': quantity,
        'unit': unit,
        'min_stock': minStock,
        'supplier_name': supplierName,
        'purchase_price': purchasePrice,
        'description': description,
        'last_updated': lastUpdated.toIso8601String(),
      };

  factory StockItem.fromMap(Map<String, dynamic> map) => StockItem(
        id: map['id'] as String,
        code: map['code'] as String? ?? '',
        name: map['name'] as String,
        brand: map['brand'] as String? ?? '',
        category: map['category'] as String? ?? '',
        quantity: (map['quantity'] as num).toDouble(),
        unit: map['unit'] as String? ?? 'metre',
        minStock: (map['min_stock'] as num).toDouble(),
        supplierName: map['supplier_name'] as String? ?? '',
        purchasePrice: (map['purchase_price'] as num?)?.toDouble() ?? 0,
        description: map['description'] as String? ?? '',
        lastUpdated: DateTime.parse(map['last_updated'] as String),
      );
}

class SupplierProduct {
  SupplierProduct({required this.name, required this.price, this.unit = 'metre'});
  final String name;
  final double price;
  final String unit;

  Map<String, dynamic> toMap() => {'name': name, 'price': price, 'unit': unit};

  factory SupplierProduct.fromMap(Map<String, dynamic> map) => SupplierProduct(
        name: map['name'] as String,
        price: (map['price'] as num).toDouble(),
        unit: map['unit'] as String? ?? 'metre',
      );
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

  Map<String, dynamic> toInsertMap() => {
        'name': name,
        'contact_person': contactPerson,
        'phone': phone,
        'email': email,
        'category': category,
        'address': address,
        'notes': notes,
        'products': products.map((p) => p.toMap()).toList(),
      };

  factory Supplier.fromMap(Map<String, dynamic> map) => Supplier(
        id: map['id'] as String,
        name: map['name'] as String,
        contactPerson: map['contact_person'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        email: map['email'] as String? ?? '',
        category: map['category'] as String? ?? '',
        address: map['address'] as String? ?? '',
        notes: map['notes'] as String? ?? '',
        products: (map['products'] as List<dynamic>? ?? [])
            .map((e) => SupplierProduct.fromMap(e as Map<String, dynamic>))
            .toList(),
      );
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

  Map<String, dynamic> toInsertMap() => {
        'supplier_name': supplierName,
        'product_name': productName,
        'quantity': quantity,
        'unit': unit,
        'delivery_date': deliveryDate.toIso8601String(),
        'notes': notes,
      };

  factory StockRequest.fromMap(Map<String, dynamic> map) => StockRequest(
        id: map['id'] as String,
        supplierName: map['supplier_name'] as String? ?? '',
        productName: map['product_name'] as String,
        quantity: (map['quantity'] as num).toDouble(),
        unit: map['unit'] as String? ?? 'metre',
        deliveryDate: DateTime.parse(map['delivery_date'] as String),
        notes: map['notes'] as String? ?? '',
      );
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stock_models.dart';

class StockNotifier extends StateNotifier<List<StockItem>> {
  StockNotifier() : super(_seed());
  int _seq = 6;

  static List<StockItem> _seed() {
    final now = DateTime(2026, 7, 14, 12, 28);
    return [
      StockItem(
        id: 'stk-1',
        code: 'RAY-002',
        name: 'Alüminyum Perde Rayı 3m',
        brand: 'Ray Sistemleri Ltd.',
        category: 'Aksesuar',
        quantity: 18,
        unit: 'adet',
        minStock: 20,
        supplierName: 'Ray Sistemleri Ltd.',
        purchasePrice: 210,
        lastUpdated: now,
      ),
      StockItem(
        id: 'stk-2',
        code: 'TUL-001',
        name: 'Beyaz Tül Kumaş',
        brand: 'Aydınlı Tekstil',
        category: 'Kumaş',
        quantity: 145,
        unit: 'metre',
        minStock: 50,
        supplierName: 'Aydınlı Tekstil',
        purchasePrice: 42,
        lastUpdated: now,
      ),
      StockItem(
        id: 'stk-3',
        code: 'FON-014',
        name: 'Blackout Fon Kumaş - Krem',
        brand: 'Fon Center',
        category: 'Kumaş',
        quantity: 30,
        unit: 'metre',
        minStock: 40,
        supplierName: 'Fon Center',
        purchasePrice: 78,
        lastUpdated: now,
      ),
      StockItem(
        id: 'stk-4',
        code: 'GUN-003',
        name: 'Güneşlik Kumaş - Antrasit',
        brand: 'Fon Center',
        category: 'Kumaş',
        quantity: 85,
        unit: 'metre',
        minStock: 30,
        supplierName: 'Fon Center',
        purchasePrice: 65,
        lastUpdated: now,
      ),
      StockItem(
        id: 'stk-5',
        code: 'PIL-009',
        name: 'Pileli Bant 2.5cm',
        brand: 'Aksesuar Dünyası',
        category: 'Aksesuar',
        quantity: 8,
        unit: 'top',
        minStock: 10,
        supplierName: 'Aksesuar Dünyası',
        purchasePrice: 35,
        lastUpdated: now,
      ),
      StockItem(
        id: 'stk-6',
        code: 'ZEB-007',
        name: 'Zebra Perde Kumaşı - Gri',
        brand: 'Modern Perde San.',
        category: 'Kumaş',
        quantity: 60,
        unit: 'metre',
        minStock: 25,
        supplierName: 'Modern Perde San.',
        purchasePrice: 95,
        lastUpdated: now,
      ),
    ];
  }

  void addItem(StockItem item) => state = [...state, item];

  void adjustQuantity(String id, double delta) {
    state = [
      for (final s in state)
        if (s.id == id) s.copyWith(quantity: s.quantity + delta) else s,
    ];
  }

  void removeItem(String id) => state = state.where((s) => s.id != id).toList();

  String nextId() {
    _seq += 1;
    return 'stk-$_seq';
  }
}

final stockProvider =
    StateNotifierProvider<StockNotifier, List<StockItem>>((ref) => StockNotifier());

class SuppliersNotifier extends StateNotifier<List<Supplier>> {
  SuppliersNotifier() : super(_seed());
  int _seq = 3;

  static List<Supplier> _seed() {
    return [
      Supplier(
        id: 'sup-1',
        name: 'Aydınlı Tekstil',
        contactPerson: 'Kemal Aydın',
        phone: '02123456789',
        email: 'info@aydinlitekstil.com',
        category: 'Kumaş',
        address: 'Merter, İstanbul',
        products: [
          SupplierProduct(name: 'Beyaz Tül Kumaş (metre)', price: 42),
          SupplierProduct(name: 'Krem Tül Kumaş (metre)', price: 45),
        ],
      ),
      Supplier(
        id: 'sup-2',
        name: 'Fon Center',
        contactPerson: 'Serkan Yıldız',
        phone: '02129876543',
        category: 'Kumaş',
        products: [
          SupplierProduct(name: 'Blackout Fon Kumaş (metre)', price: 78),
          SupplierProduct(name: 'Güneşlik Kumaş (metre)', price: 65),
        ],
      ),
      Supplier(
        id: 'sup-3',
        name: 'Ray Sistemleri Ltd.',
        contactPerson: 'Onur Kaplan',
        phone: '02165432109',
        category: 'Aksesuar',
        products: [
          SupplierProduct(name: 'Alüminyum Ray 3m', price: 210, unit: 'adet'),
        ],
      ),
    ];
  }

  void addSupplier(Supplier supplier) => state = [...state, supplier];

  void removeSupplier(String id) =>
      state = state.where((s) => s.id != id).toList();

  void addProductToSupplier(String supplierId, SupplierProduct product) {
    state = [
      for (final s in state)
        if (s.id == supplierId)
          Supplier(
            id: s.id,
            name: s.name,
            contactPerson: s.contactPerson,
            phone: s.phone,
            email: s.email,
            category: s.category,
            address: s.address,
            notes: s.notes,
            products: [...s.products, product],
          )
        else
          s,
    ];
  }

  String nextId() {
    _seq += 1;
    return 'sup-$_seq';
  }
}

final suppliersProvider =
    StateNotifierProvider<SuppliersNotifier, List<Supplier>>(
        (ref) => SuppliersNotifier());

class StockRequestsNotifier extends StateNotifier<List<StockRequest>> {
  StockRequestsNotifier() : super([]);
  int _seq = 0;

  void addRequest(StockRequest r) => state = [...state, r];

  void removeRequest(String id) =>
      state = state.where((r) => r.id != id).toList();

  String nextId() {
    _seq += 1;
    return 'req-$_seq';
  }
}

final stockRequestsProvider =
    StateNotifierProvider<StockRequestsNotifier, List<StockRequest>>(
        (ref) => StockRequestsNotifier());

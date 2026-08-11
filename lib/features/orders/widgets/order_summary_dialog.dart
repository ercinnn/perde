import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order_models.dart';

void showOrderSummaryDialog(BuildContext context, Order order) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Yıldız Perde Dekorasyon — Müşteri Siparişi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                const Text('Müşteri Bilgileri',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Ad Soyad: ${order.customerName}'),
                Text('Telefon: ${order.phone}'),
                Text('Adres: ${order.address}'),
                const SizedBox(height: 16),
                const Text('Sipariş Detayları',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Sipariş Tarihi: ${Formatters.date(order.orderDate)}'),
                Text(
                    'Teslimat Tarihi: ${Formatters.date(order.deliveryDate)} (${order.deliveryType.label})'),
                const SizedBox(height: 12),
                Table(
                  border: TableBorder.all(color: const Color(0xFFE3E7EE)),
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(2),
                  },
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(color: Color(0xFF13223B)),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Ürün Tipi',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Oda',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Adet',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Tutar (TL)',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    for (final item in order.items)
                      TableRow(children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(item.productType.label),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(item.room.label),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text('${item.quantity}'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(Formatters.currency(item.total)),
                        ),
                      ]),
                  ],
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Toplam: ${Formatters.currency(order.subtotal)}'),
                      Text('İndirim: ${Formatters.currency(order.discount)}'),
                      Text('Kapora: ${Formatters.currency(order.deposit)}'),
                      Text('Kalan: ${Formatters.currency(order.remaining)}',
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Kapat'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

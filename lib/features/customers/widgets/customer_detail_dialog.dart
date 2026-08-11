import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order_models.dart';
import 'whatsapp_dialog.dart';

void showCustomerDetailDialog(BuildContext context, CustomerSummary customer) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Text('Telefon: ${customer.phone}'),
                Text('Adres: ${customer.address}'),
                Text('Sipariş Sayısı: ${customer.orders.length}'),
                Text('Toplam Tutar: ${Formatters.currency(customer.totalAmount)}'),
                Text('Toplam Kapora: ${Formatters.currency(customer.totalDeposit)}'),
                Text('Toplam Kalan: ${Formatters.currency(customer.totalRemaining)}'),
                Text('Son Sipariş: ${Formatters.date(customer.latestOrder.orderDate)}'),
                const SizedBox(height: 18),
                const Text('Sipariş Geçmişi',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                for (final o in customer.orders)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      children: [
                        Text(
                          '${o.code} — ${o.items.isNotEmpty ? o.items.first.productType.label : "Ürün"} '
                          '(${Formatters.currency(o.grandTotal)}, ${o.status.label})',
                        ),
                        TextButton(
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('PDF indiriliyor (demo)')),
                          ),
                          child: const Text('📄 PDF'),
                        ),
                        TextButton(
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Fotoğraf açılıyor (demo)')),
                          ),
                          child: const Text('📷 Foto'),
                        ),
                        TextButton(
                          onPressed: () => showWhatsAppDialog(context, o),
                          style: TextButton.styleFrom(foregroundColor: const Color(0xFF25D366)),
                          child: const Text('📱 WhatsApp'),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
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

class OrderStatusColors {
  static Color of(String label) {
    switch (label) {
      case 'Teslim Edildi':
        return AppColors.success;
      case 'İptal':
        return AppColors.danger;
      case 'Hazırlanıyor':
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }
}

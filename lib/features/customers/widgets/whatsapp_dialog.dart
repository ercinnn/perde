import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order_models.dart';

void showWhatsAppDialog(BuildContext context, Order order) {
  final phoneCtrl = TextEditingController(text: order.phone);
  final messageCtrl = TextEditingController();

  String template(String kind) {
    switch (kind) {
      case 'received':
        return 'Sayın Müşterimiz,\n\nSiparişinizdeki bilgiler aşağıdaki gibidir:\n\n'
            '🏠 Yıldız Perde Dekorasyon\n'
            '📦 Ürün           : ${order.items.isNotEmpty ? order.items.first.productType.label : '-'}\n'
            '📅 Tahmini Teslim : ${Formatters.date(order.deliveryDate)}\n'
            '\n💰 Toplam Tutar   : ${Formatters.currency(order.grandTotal)}\n'
            '💳 Kalan Ödeme    : ${Formatters.currency(order.remaining)}';
      case 'ready':
        return 'Sayın Müşterimiz, siparişiniz teslimata hazırdır. '
            'Teslimat tarihi: ${Formatters.date(order.deliveryDate)}.';
      default:
        return 'Sayın Müşterimiz, ${Formatters.currency(order.remaining)} tutarındaki '
            'kalan ödemenizi hatırlatmak isteriz.';
    }
  }

  messageCtrl.text = template('received');

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📱 WhatsApp Gönder',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('Sipariş: ${order.code} — ${order.items.isNotEmpty ? order.items.first.productType.label : ''}',
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                const Text('Müşteri Telefon Numarası',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                const SizedBox(height: 6),
                TextField(controller: phoneCtrl),
                const SizedBox(height: 16),
                const Text('Hazır Şablonlar',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() => messageCtrl.text = template('received')),
                      child: const Text('Sipariş Alındı'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C3FA6)),
                      onPressed: () => setState(() => messageCtrl.text = template('ready')),
                      child: const Text('Teslimat Hazır'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A227)),
                      onPressed: () => setState(() => messageCtrl.text = template('reminder')),
                      child: const Text('Ödeme Hatırlatma'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Mesaj Metni (düzenleyebilirsiniz)',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                const SizedBox(height: 6),
                TextField(controller: messageCtrl, maxLines: 6),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('İptal'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('WhatsApp mesajı gönderildi (demo)')),
                        );
                      },
                      child: const Text("📱 WhatsApp'a Gönder"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

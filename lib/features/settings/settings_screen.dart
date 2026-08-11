import 'package:flutter/material.dart';
import '../../shared/widgets/labeled_field.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/section_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _businessNameCtrl = TextEditingController(text: 'Yıldız Perde Dekorasyon');
  final _phoneCtrl = TextEditingController(text: '02121234567');
  final _addressCtrl = TextEditingController(text: 'Merkez Mah. Perde Sok. No:1');
  final _taxNoCtrl = TextEditingController();
  bool _whatsappNotifications = true;
  bool _stockAlerts = true;
  bool _deliveryReminders = true;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Ayarlar',
      icon: '⚙️',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('İşletme Bilgileri',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                LabeledField(label: 'İşletme Adı', child: TextField(controller: _businessNameCtrl)),
                const SizedBox(height: 14),
                FieldRow(children: [
                  LabeledField(label: 'Telefon', width: 220, child: TextField(controller: _phoneCtrl)),
                  LabeledField(label: 'Vergi No', width: 220, child: TextField(controller: _taxNoCtrl)),
                ]),
                const SizedBox(height: 14),
                LabeledField(label: 'Adres', child: TextField(controller: _addressCtrl)),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () => ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Ayarlar kaydedildi (demo)'))),
                  child: const Text('KAYDET'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bildirim Ayarları',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('WhatsApp bildirimleri'),
                  value: _whatsappNotifications,
                  onChanged: (v) => setState(() => _whatsappNotifications = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Kritik stok uyarıları'),
                  value: _stockAlerts,
                  onChanged: (v) => setState(() => _stockAlerts = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Teslimat hatırlatıcıları'),
                  value: _deliveryReminders,
                  onChanged: (v) => setState(() => _deliveryReminders = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kullanıcılar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                const _UserRow(name: 'Admin', role: 'Yönetici'),
                const _UserRow(name: 'Terzi Ekibi', role: 'Operasyon'),
                const SizedBox(height: 10),
                OutlinedButton(onPressed: () {}, child: const Text('+ Kullanıcı Ekle')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.name, required this.role});
  final String name;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 18)),
          const SizedBox(width: 12),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Text(role, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

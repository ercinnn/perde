import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/section_card.dart';
import '../../shared/widgets/status_badge.dart';

class LicenseScreen extends StatefulWidget {
  const LicenseScreen({super.key});

  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen> {
  final _keyCtrl = TextEditingController(text: 'YPD-2026-DEMO-0001');
  bool _active = true;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Lisans',
      icon: '🔑',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Lisans Durumu',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    StatusBadge(
                      label: _active ? 'Aktif' : 'Pasif',
                      tone: _active ? BadgeTone.green : BadgeTone.red,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _keyCtrl,
                  decoration: const InputDecoration(labelText: 'Lisans Anahtarı'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _active = _keyCtrl.text.trim().isNotEmpty);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lisans doğrulandı (demo)')),
                    );
                  },
                  child: const Text('DOĞRULA'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Lisans Bilgileri',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                const _InfoRow(label: 'Plan', value: 'Pro'),
                const _InfoRow(label: 'Başlangıç', value: '01.01.2026'),
                const _InfoRow(label: 'Bitiş', value: '01.01.2027'),
                const _InfoRow(label: 'Kullanıcı Sayısı', value: '3 / 5'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 160, child: Text(label, style: const TextStyle(color: AppColors.textMuted))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

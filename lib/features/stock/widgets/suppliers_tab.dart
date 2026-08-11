import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/stock_models.dart';
import '../../../data/providers/stock_provider.dart';
import '../../../shared/widgets/labeled_field.dart';
import '../../../shared/widgets/section_card.dart';

class SuppliersTab extends ConsumerStatefulWidget {
  const SuppliersTab({super.key});

  @override
  ConsumerState<SuppliersTab> createState() => _SuppliersTabState();
}

class _SuppliersTabState extends ConsumerState<SuppliersTab> {
  final _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final suppliers = ref.watch(suppliersProvider);
    final query = _searchCtrl.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? suppliers
        : suppliers.where((s) => s.name.toLowerCase().contains(query)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(hintText: 'Firma ara...'),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => _showSupplierForm(context),
              child: const Text('+ Yeni Tedarikçi'),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF6C3FA6)),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("PDF'den fiyat içe aktarılıyor (demo)")),
              ),
              child: const Text("📄 PDF'den Fiyat İçe Aktar"),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (final s in filtered)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => _showSupplierDetail(context, s),
              child: SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('${s.contactPerson} · ${s.phone}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12.5)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showSupplierDetail(BuildContext context, Supplier s) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Text('Yetkili: ${s.contactPerson}'),
                Text('Telefon: ${s.phone}'),
                Text('E-posta: ${s.email.isEmpty ? "-" : s.email}'),
                Text('Kategori: ${s.category}'),
                Text('Adres: ${s.address.isEmpty ? "-" : s.address}'),
                Text('Notlar: ${s.notes.isEmpty ? "-" : s.notes}'),
                const SizedBox(height: 10),
                const Text('Ürünler:', style: TextStyle(fontWeight: FontWeight.w700)),
                for (final p in s.products)
                  Text('- ${p.name}: ${Formatters.currency(p.price)} / ${p.unit}'),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC0392B)),
                      onPressed: () {
                        ref.read(suppliersProvider.notifier).removeSupplier(s.id);
                        Navigator.of(context).pop();
                      },
                      child: const Text('SİL'),
                    ),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('DÜZENLE'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('WhatsApp açılıyor (demo)')),
                      ),
                      child: const Text('WhatsApp'),
                    ),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Kapat'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSupplierForm(BuildContext context) {
    final nameCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final categoryCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Yeni Tedarikçi',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  FieldRow(children: [
                    LabeledField(label: 'Firma Adı *', width: 220, child: TextField(controller: nameCtrl)),
                    LabeledField(label: 'Yetkili', width: 200, child: TextField(controller: contactCtrl)),
                  ]),
                  const SizedBox(height: 14),
                  FieldRow(children: [
                    LabeledField(label: 'Telefon', width: 180, child: TextField(controller: phoneCtrl)),
                    LabeledField(label: 'E-posta', width: 200, child: TextField(controller: emailCtrl)),
                    LabeledField(label: 'Kategori', width: 150, child: TextField(controller: categoryCtrl)),
                  ]),
                  const SizedBox(height: 14),
                  LabeledField(label: 'Adres', child: TextField(controller: addressCtrl)),
                  const SizedBox(height: 14),
                  LabeledField(label: 'Notlar', child: TextField(controller: notesCtrl)),
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
                        onPressed: () {
                          if (nameCtrl.text.trim().isEmpty) return;
                          final notifier = ref.read(suppliersProvider.notifier);
                          notifier.addSupplier(Supplier(
                            id: notifier.nextId(),
                            name: nameCtrl.text.trim(),
                            contactPerson: contactCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                            email: emailCtrl.text.trim(),
                            category: categoryCtrl.text.trim(),
                            address: addressCtrl.text.trim(),
                            notes: notesCtrl.text.trim(),
                          ));
                          Navigator.of(context).pop();
                        },
                        child: const Text('KAYDET'),
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
}

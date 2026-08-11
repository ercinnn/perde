import 'package:flutter/material.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/section_card.dart';

class _Formula {
  const _Formula(this.title, this.formula, this.notes);
  final String title;
  final String formula;
  final List<String> notes;
}

const _formulas = [
  _Formula(
    'Tül, Fon',
    'Tutar = En (m) × (Pile % ÷ 100 + 1) × Birim Fiyat',
    [
      'En, 50\'den büyük girilirse otomatik metreye çevrilir (÷100)',
      'Pile yüzdesi çarpana eklenir — örn %150 pile ise çarpan 2.5 olur',
      'Boy hesaba katılmaz',
    ],
  ),
  _Formula(
    'Stor, Zebra',
    'Tutar = En (m) × Boy (m) × Birim Fiyat',
    [
      'En, en az 1.0 m sayılır ve yukarı 10 cm\'in katına yuvarlanır',
      'Boy, en az 2.0 m sayılır ve yukarı 10 cm\'in katına yuvarlanır',
    ],
  ),
  _Formula(
    'Pliseli / Ahşap Jaluzi / Alüminyum Jaluzi',
    'Tutar = max(En (m) × Boy (m), 1 m²) × Birim Fiyat',
    [
      'En ve Boy her zaman cm olarak girilir',
      'İkisi de yukarı 10 cm\'in katına yuvarlanır (örn. 56 → 60, 65 → 70)',
      'Toplam alan en az 1 m² sayılır (küçük ölçülerde bile 1 m² üzerinden fiyatlanır)',
    ],
  ),
  _Formula(
    'Güneşlik, Blackout, Karartma',
    'Tutar = (En (m) + 0.3) × Birim Fiyat',
    [],
  ),
  _Formula('Korniş', 'Tutar = En (m) × Birim Fiyat', []),
  _Formula('Dikey Perde', 'Tutar = En (m) × Boy (m) × Birim Fiyat', []),
];

class CalcNoteScreen extends StatelessWidget {
  const CalcNoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Hesaplama Notu',
      icon: '📐',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Sipariş Formu'nda ürün tutarları, ürün tipine göre aşağıdaki formüllerle otomatik hesaplanır.",
          ),
          const SizedBox(height: 16),
          for (final f in _formulas)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Text(f.formula, style: const TextStyle(fontFamily: 'monospace', fontSize: 13.5)),
                    if (f.notes.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      for (final n in f.notes)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('•  $n'),
                        ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

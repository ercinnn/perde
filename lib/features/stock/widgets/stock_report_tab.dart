import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/providers/stock_provider.dart';
import '../../../shared/widgets/section_card.dart';

class StockReportTab extends ConsumerWidget {
  const StockReportTab({super.key});

  String _buildReport(WidgetRef ref) {
    final items = ref.read(stockProvider);
    final critical = items.where((i) => i.isCritical).length;
    final buffer = StringBuffer();
    buffer.writeln('=' * 58);
    buffer.writeln('STOK DURUMU ÖZET');
    buffer.writeln('=' * 58);
    buffer.writeln();
    buffer.writeln('Toplam Ürün: ${items.length}');
    buffer.writeln('Kritik Stok: $critical');
    buffer.writeln();
    buffer.writeln('-' * 58);
    buffer.writeln('STOK DETAYLARI');
    buffer.writeln('-' * 58);
    for (final i in items) {
      buffer.writeln();
      buffer.writeln('Ürün: ${i.name}');
      buffer.writeln('  Kod: ${i.code}');
      buffer.writeln('  Miktar: ${Formatters.number(i.quantity)} ${i.unit}');
      buffer.writeln('  Min. Stok: ${Formatters.number(i.minStock)}');
      buffer.writeln('  Durum: ${i.isCritical ? "Kritik" : "Normal"}');
      buffer.writeln('  Tedarikçi: ${i.supplierName}');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _StockReportBody(builder: _buildReport);
  }
}

class _StockReportBody extends ConsumerStatefulWidget {
  const _StockReportBody({required this.builder});
  final String Function(WidgetRef ref) builder;

  @override
  ConsumerState<_StockReportBody> createState() => _StockReportBodyState();
}

class _StockReportBodyState extends ConsumerState<_StockReportBody> {
  String? _report;

  @override
  Widget build(BuildContext context) {
    _report ??= widget.builder(ref);
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Stok Hareket Raporu',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ElevatedButton(
                onPressed: () => setState(() => _report = widget.builder(ref)),
                child: const Text('RAPOR GÜNCELLE'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F7F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(_report!, style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5)),
          ),
        ],
      ),
    );
  }
}

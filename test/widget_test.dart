import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yildiz_perde/main.dart';

void main() {
  testWidgets('Dashboard loads with sidebar', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: YildizPerdeApp()));
    await tester.pumpAndSettle();

    expect(find.text('Yıldız Perde Dekorasyon'), findsWidgets);
    expect(find.text('Kontrol Paneli'), findsWidgets);
  });
}

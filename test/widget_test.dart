import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('MDHP app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MdhpMobileApp());
    expect(find.byType(MdhpMobileApp), findsOneWidget);
  });
}

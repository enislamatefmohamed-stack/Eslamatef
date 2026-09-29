import 'package:flutter_test/flutter_test.dart';
import 'package:eslam_atef_code_ai/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EslamAtefApp());
    expect(find.byType(EslamAtefApp), findsOneWidget);
  });
}

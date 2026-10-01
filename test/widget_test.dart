import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eslam_atef_code_ai/main.dart';
import 'package:eslam_atef_code_ai/services/site_data_service.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await SiteDataService.instance.init();
    await tester.pumpWidget(const EslamAtefApp());
    expect(find.byType(EslamAtefApp), findsOneWidget);
  });
}

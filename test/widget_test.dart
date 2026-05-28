import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:leaf_fresh/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Splash screen shows app title', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const NgstradamusApp());
    expect(find.text('농스트라다무스'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}

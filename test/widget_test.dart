import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows the Mystic onboarding', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MysticApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Your inner world\nhas a language.'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/app.dart';

void main() {
  testWidgets('shows the Mystic onboarding', (tester) async {
    await tester.pumpWidget(const MysticApp());
    expect(find.text('Your inner world\nhas a language.'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}

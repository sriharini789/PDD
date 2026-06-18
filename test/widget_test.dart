import 'package:flutter_test/flutter_test.dart';
import 'package:research_ai/main.dart';

void main() {
  testWidgets('Splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ResearchAIApp());

    // Verify that the splash screen shows branding text
    expect(find.text('Research AI'), findsOneWidget);
  });
}

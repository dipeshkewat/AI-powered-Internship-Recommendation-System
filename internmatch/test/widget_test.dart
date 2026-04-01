import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internmatch/main.dart';

void main() {
  testWidgets('InternMatch app launches', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: InternMatchApp()),
    );
    await tester.pump();

    // App should load with the splash screen showing "InternMatch"
    expect(find.text('InternMatch'), findsWidgets);
  });
}

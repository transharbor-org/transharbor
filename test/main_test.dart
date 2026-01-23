import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/main.dart';

void main() {
  group('Main App', () {
    testWidgets('app starts without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(const TransHarborApp());
      
      // App should render without errors
      expect(find.byType(TransHarborApp), findsOneWidget);
    });

    testWidgets('app is wrapped with MaterialApp', (WidgetTester tester) async {
      await tester.pumpWidget(const TransHarborApp());
      
      // Should use Material design
      expect(tester.allWidgets.any((widget) => widget.toString().contains('Material')), true);
    });
  });
}

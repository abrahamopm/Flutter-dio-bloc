import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dio_bloc/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const MyApp());
      await tester.pump();
      
      // Verify that our rejuvenated app shows the 'STOREBOARD' title.
      expect(find.text('STOREBOARD'), findsOneWidget);
    });
  });
}

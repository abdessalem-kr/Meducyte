import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Smoke test - basic widget rendering', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Meducyte App'),
          ),
        ),
      ),
    );

    expect(find.text('Meducyte App'), findsOneWidget);
  });
}

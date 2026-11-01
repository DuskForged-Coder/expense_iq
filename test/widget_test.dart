import 'package:expense_iq/shared/widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders glass card content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GradientShell(
            child: GlassCard(child: Text('ExpenseIQ')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ExpenseIQ'), findsOneWidget);
    expect(find.byType(GlassCard), findsOneWidget);
  });
}

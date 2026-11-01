import 'package:expense_iq/core/di/service_locator.dart';
import 'package:expense_iq/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app launches to authentication flow', (tester) async {
    await configureDependencies();
    await tester.pumpWidget(const ExpenseIqApp());
    await tester.pumpAndSettle();

    expect(find.text('ExpenseIQ'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });
}

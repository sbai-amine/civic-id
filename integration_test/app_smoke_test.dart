import 'package:civic_key/app/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app starts', (tester) async {
    await tester.pumpWidget(const BridgeIdApp());
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.text('BridgeID'), findsWidgets);
  });
}

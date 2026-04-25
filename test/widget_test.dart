import 'package:flutter_test/flutter_test.dart';

import 'package:civic_key/app/app.dart';

void main() {
  testWidgets('BridgeID app builds and reaches login or dashboard', (tester) async {
    await tester.pumpWidget(const BridgeIdApp());
    await tester.pump();
    expect(find.text('BridgeID'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    final signIn = find.text('Sign in');
    final welcome = find.textContaining('Welcome back');
    expect(
      signIn.evaluate().isNotEmpty || welcome.evaluate().isNotEmpty,
      isTrue,
    );
  });
}

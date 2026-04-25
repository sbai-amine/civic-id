import 'package:flutter_test/flutter_test.dart';

import 'package:civic_key_agent/app/civic_key_agent_app.dart';

void main() {
  testWidgets('Agent app builds', (tester) async {
    await tester.pumpWidget(const BridgeIdVerifierApp());
    expect(find.text('BridgeID Verifier'), findsOneWidget);
  });
}

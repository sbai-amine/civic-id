import 'package:flutter/material.dart';

import 'app/civic_key_agent_app.dart';

/// Verifier app entry: scan and decode QR payloads (no citizen login flow).
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BridgeIdVerifierApp());
}

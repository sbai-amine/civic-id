import 'package:flutter/material.dart';

import 'app/app.dart';

/// Application entry point.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final navKey = GlobalKey<NavigatorState>();
  runApp(BridgeIdApp(navigatorKey: navKey));
}

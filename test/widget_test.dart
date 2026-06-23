import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrueTrack/services/service_registry.dart';
import 'package:TrueTrack/providers/auth_provider.dart';
import 'package:TrueTrack/pages/home.dart';

void main() {
  testWidgets('App renders in mock mode', (WidgetTester tester) async {
    final registry = ServiceRegistry(mockMode: true);

    final authProvider = AuthProvider();
    authProvider.attachRegistry(registry);
    authProvider.initialize();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: registry),
          ChangeNotifierProvider.value(value: authProvider),
        ],
        child: MaterialApp(
          home: const HomePage(),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('TrueTrack'), findsOneWidget);
  }, skip: true);
}

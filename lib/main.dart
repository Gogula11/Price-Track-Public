import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'pages/home.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'services/notification_service.dart';
import 'services/rapidapi_client.dart';
import 'services/firestore_service.dart';
import 'services/amazon_service.dart';
import 'services/flipkart_service.dart';
import 'services/ai_service.dart';
import 'services/service_registry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? crash;
  try {
    await dotenv.load();

    final rapidApiClient = RapidApiClient();
    final firestoreService = FirestoreService();
    final amazonService = AmazonService(rapidApiClient);
    final flipkartService = FlipkartService(rapidApiClient);
    final aiService = AiService(rapidApiClient);
    final notificationService = NotificationService();

    final registry = ServiceRegistry(
      amazonService: amazonService,
      flipkartService: flipkartService,
      aiService: aiService,
      firestoreService: firestoreService,
      notificationService: notificationService,
      mockMode: true,
    );

    final authProvider = AuthProvider();
    authProvider.attachRegistry(registry);
    authProvider.initialize();

    runApp(MyApp(
      registry: registry,
      authProvider: authProvider,
    ));
  } catch (e, s) {
    crash = 'CRASH: $e\n$s';
  }

  if (crash != null) {
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText(crash),
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  final ServiceRegistry registry;
  final AuthProvider authProvider;

  const MyApp({
    super.key,
    required this.registry,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: registry),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(),
        ),
      ],
      child: const _App(),
    );
  }
}

class _App extends StatefulWidget {
  const _App();

  @override
  State<_App> createState() => _AppState();
}

class _AppState extends State<_App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      home: const HomePage(),
    );
  }
}

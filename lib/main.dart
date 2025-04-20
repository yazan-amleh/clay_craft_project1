import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/app_state.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';
import 'firebase_options.dart';
import 'package:clay_craft_project/navigation/app_router.dart';
import 'package:clay_craft_project/provider/pottery_data_provider.dart';
import 'package:clay_craft_project/services/firestore_service.dart';
import 'package:clay_craft_project/services/auth_service.dart';

final Logger _logger = Logger('FirebaseAuth');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint(
        '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
  });

  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      _logger.info('*User is currently signed out!');
    } else {
      _logger.info('*User is signed in!');
    }
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        Provider<FirestoreService>(create: (context) => FirestoreService()),
        Provider<AuthService>(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => PotteryDataProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clay Craft',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 108, 89, 63),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 108, 89, 63),
          primary: const Color.fromARGB(255, 108, 89, 63),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 108, 89, 63),
            foregroundColor: Colors.white,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 108, 89, 63),
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: AppRouter.home,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

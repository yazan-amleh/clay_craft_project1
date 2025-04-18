import 'package:clay_craft_project/fav_page.dart';
import 'package:clay_craft_project/shopping_page.dart';
import 'package:flutter/material.dart';
import 'first_page.dart';
import 'package:provider/provider.dart';
import 'provider/app_state.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';
import 'firebase_options.dart';

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
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const FirstPage(),
      routes: {
        '/favorites': (ctx) => FavPage(),
        '/shopping': (ctx) => ShoppingPage(),
      },
    );
  }
}

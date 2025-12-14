import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:recipe/models/br_database.dart';
import 'package:recipe/notInUse/brin_db.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:recipe/pages/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enforce portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp();
  await database.initialize();
  await Supabase.initialize(
    url: 'https://dbofzegzkrkdwwefhlkh.supabase.co',
    anonKey: 'sb_publishable_gf9rw3O64RtxB7qXiz0HNQ_LuVqZQzT',
  );

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => database()),
    ],
    child: const MyApp(),
  ));

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: SplashScreen(), // Set SplashScreen as the initial widget
    );
  }
}

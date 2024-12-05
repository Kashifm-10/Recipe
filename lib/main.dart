import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:recipe/models/br_database.dart';
import 'package:recipe/notInUse/brin_db.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:recipe/splash_screen.dart';

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
    url: 'https://vgkxpwyszheougrhippw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZna3hwd3lzemhlb3VncmhpcHB3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjk2NjA3NzgsImV4cCI6MjA0NTIzNjc3OH0.YzFunbFqLYXYn9-trGWtgElmi9rVp-D5_m_yuTXy0qo',
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

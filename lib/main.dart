import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:recipe/models/br_database.dart';
import 'package:recipe/notInUse/brin_db.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:recipe/pages/splash_screen.dart';

// Desktop window manager
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enforce portrait mode on mobile
  if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Initialize database
  await database.initialize();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://dbofzegzkrkdwwefhlkh.supabase.co',
    anonKey: 'sb_publishable_gf9rw3O64RtxB7qXiz0HNQ_LuVqZQzT',
  );

  // Initialize window_manager for desktop
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    // Get screen size using getBounds
    Rect bounds = await windowManager.getBounds();
    double screenHeight = bounds.height;

    // Target ratio: 9:16 (portrait)
    const double aspectRatio = 9 / 20 ;
    double windowWidth = screenHeight * aspectRatio;

    WindowOptions windowOptions = WindowOptions(
      size: Size(windowWidth, screenHeight),
      center: true,
      minimumSize: Size(windowWidth, screenHeight),
      maximumSize: Size(windowWidth, screenHeight),
      title: "Recipes",
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setAspectRatio(aspectRatio); // keeps ratio
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}

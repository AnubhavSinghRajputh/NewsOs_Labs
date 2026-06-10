import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dmgwkgadhnpjnnjklnqh.supabase.co',
    publishableKey: 'sb_publishable_Lspy0F1ek5gInIYOkY087A_IGPG3Xkg',
  );

  runApp(const QuantNewsApp());
}

class QuantNewsApp extends StatelessWidget {
  const QuantNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuantNews',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF070709),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

/// Global Supabase client shortcut for QuantNews screens.
SupabaseClient get supabase => Supabase.instance.client;

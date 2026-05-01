// ignore: uri_does_not_exist
import 'package:flutter/material.dart';
// ignore: uri_does_not_exist
import 'package:flutter/services.dart';
import 'screens/skin_scanner_screen.dart'; // add this import

// inside routes:
'/scan': (context) => const SkinScannerScreen(),

import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const DermaAIApp());
}

class DermaAIApp extends StatelessWidget {
  const DermaAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Derma AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'sans-serif',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2ECC8F),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/home',
      routes: {
      
  
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
//This is main dart
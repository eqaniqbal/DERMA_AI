import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


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
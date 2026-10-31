import 'package:flutter/material.dart';
import 'features/authentication/screens/login_screen.dart';

void main() {
  runApp(const BrightLoopApp());
}

class BrightLoopApp extends StatelessWidget {
  const BrightLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BrightLoop',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
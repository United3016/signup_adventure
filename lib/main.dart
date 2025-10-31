// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart'; // Import the WelcomeScreen

void main() {
  runApp(const SignupAdventureApp());
}

class SignupAdventureApp extends StatelessWidget {
  const SignupAdventureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Signup Adventure ',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Roboto',
      ),
      // Set the first imported screen as home
      home: const WelcomeScreen(), 
      debugShowCheckedModeBanner: false,
    );
  }
}
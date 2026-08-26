import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const QuronApp());
}

class QuronApp extends StatelessWidget {
  const QuronApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Qur'on o'rganish",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0E9F6E),
          brightness: Brightness.light,
        ),
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFEAFBF4),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFEAFBF4),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF16241F),
          ),
          iconTheme: IconThemeData(color: Color(0xFF16241F)),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

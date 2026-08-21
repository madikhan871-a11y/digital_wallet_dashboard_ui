import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const HomeMaintenanceApp());
}

class HomeMaintenanceApp extends StatelessWidget {
  const HomeMaintenanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Home Maintenance',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor:
        const Color(0xFFF6F2E9),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B765F),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
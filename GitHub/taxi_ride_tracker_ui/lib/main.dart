import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const TaxiRideTrackerApp());
}

class TaxiRideTrackerApp extends StatelessWidget {
  const TaxiRideTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Taxi Ride Tracker',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor:
        const Color(0xFF111311),
      ),
      home: const HomeScreen(),
    );
  }
}
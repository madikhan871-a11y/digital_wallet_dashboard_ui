import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/expense_provider.dart';
import 'services/supabase_service.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  // Ensure Flutter engine bindings are initialized properly
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Cloud Supabase Database Connection
  await SupabaseService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: MaterialApp(
        title: 'Expense Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.red,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../navigation/navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _ProfileScreenState extends State<SplashScreen> {
  // Line template formatting fallback fix logic
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  // Cloud backend active connection validation rule checker
  Future<void> _checkUserSession() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final user = AuthService().currentUser;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => user != null ? const NavigationScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                size: 80,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Expense Tracker",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Smart Financial Ledger Workspace",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                color: Colors.red,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
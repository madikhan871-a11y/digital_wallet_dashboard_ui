import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../navigation/navigation_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
final _emailController = TextEditingController();
final _passwordController = TextEditingController();
bool _isLoading = false;
bool _obscurePassword = true;

@override
void dispose() {
_emailController.dispose();
_passwordController.dispose();
super.dispose();
}

Future<void> _login() async {
final email = _emailController.text.trim();
final password = _passwordController.text.trim();

if (email.isEmpty || password.isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text("Please fill all fields")),
);
return;
}

setState(() => _isLoading = true);
try {
await AuthService().login(email: email, password: password);
if (mounted) {
Navigator.pushReplacement(
context,
MaterialPageRoute(builder: (_) => const NavigationScreen()),
);
}
} catch (e) {
if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text("Login Failed: ${e.toString()}")),
);
}
} finally {
if (mounted) setState(() => _isLoading = false);
}
}
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.lock_person_rounded, size: 80, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                "Welcome Back",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Login to manage your expenses",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 35),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Email",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: "Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text(
                    "Login",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      );
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}

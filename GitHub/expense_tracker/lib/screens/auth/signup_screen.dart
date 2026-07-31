import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
final _nameController = TextEditingController();
final _emailController = TextEditingController();
final _passwordController = TextEditingController();
bool _isLoading = false;

@override
void dispose() {
_nameController.dispose();
_emailController.dispose();
_passwordController.dispose();
super.dispose();
}

Future<void> _signup() async {
if (_nameController.text.trim().isEmpty ||
_emailController.text.trim().isEmpty ||
_passwordController.text.trim().isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text("Please fill all fields")),
);
return;
}

setState(() => _isLoading = true);
try {
await AuthService().signup(
email: _emailController.text.trim(),
password: _passwordController.text.trim(),
name: _nameController.text.trim(),
);
if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text("Account Created! Please Login."), backgroundColor: Colors.green),
);
Navigator.pop(context);
}
} catch (e) {
if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text(e.toString())),
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
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          const Icon(Icons.person_add_rounded, size: 80, color: Colors.red),
          const SizedBox(height: 20),
          const Text(
            "Create Account",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 35),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: "Full Name",
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
          const SizedBox(height: 20),
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
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Password",
              prefixIcon: const Icon(Icons.lock_outline),
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
              onPressed: _isLoading ? null : _signup,
              child: _isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    ),
  );
}
}

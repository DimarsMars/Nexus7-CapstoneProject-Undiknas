import 'package:flutter/material.dart';
import 'signup.dart';
import 'home_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailOrUsernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    String emailOrUsername = _emailOrUsernameController.text.trim();
    String password = _passwordController.text;

    // Simple dummy validation
    if (emailOrUsername.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username/email and password')),
      );
      return;
    }

    // Kalau validasi berhasil, langsung navigasi ke HomePage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/journeys_item.png', // Ganti dengan path gambarmu
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Login',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailOrUsernameController,
                decoration: const InputDecoration(
                  labelText: 'Email or Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupPage()),
                      );
                    },
                    child: const Text("Signup"),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _login,
                child: const Text("Login"),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

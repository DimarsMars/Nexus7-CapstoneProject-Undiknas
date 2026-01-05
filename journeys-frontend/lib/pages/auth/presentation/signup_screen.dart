import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:journeys/services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _apiService = ApiService();

  bool _isPasswordVisible = false;
  bool _isRepeatPasswordVisible = false;
  bool _isLoading = false;
  bool _showError = false;
  String _errorMessage = '';

  Future<void> _handleSignup() async {
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final repeatPassword = _repeatPasswordController.text;

    if (email.isEmpty || username.isEmpty || password.isEmpty || repeatPassword.isEmpty) {
      setState(() { _errorMessage = "All fields are required."; _showError = true; });
      return;
    }
    if (!email.contains('@')) {
      setState(() { _errorMessage = "Invalid email format (must contain @)"; _showError = true; });
      return;
    }
    if (password.length < 8) {
      setState(() { _errorMessage = "Password must be at least 8 characters long"; _showError = true; });
      return;
    }
    if (password != repeatPassword) {
      setState(() { _errorMessage = "Passwords do not match."; _showError = true; });
      return;
    }

    setState(() { _isLoading = true; _showError = false; });

    try {
      await _apiService.register(email, password, username);
      if (mounted) context.go('/login');
    } catch (e) {
      if (mounted) {
        setState(() {
          String errorMsg = e.toString().toLowerCase();
          if (errorMsg.contains('email-already-in-use') || errorMsg.contains('already exists')) {
            _errorMessage = "This email is already in use.";
          } else {
            _errorMessage = e.toString().replaceAll('Exception: ', '');
          }
          _showError = true;
        });
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 25), 
                Hero(
                  tag: 'app-logo',
                  child: Image.asset(
                    'assets/icons/logo.png',
                    height: 300, // Ukuran disamakan dengan Login (Smooth Hero)
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Signup',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                ),
                const SizedBox(height: 20),

                const Text('Email', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                const SizedBox(height: 4),
                TextFormField(controller: _emailController, decoration: _buildInputDecoration('Email')),
                const SizedBox(height: 12),

                const Text('Username', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                const SizedBox(height: 4),
                TextFormField(controller: _usernameController, decoration: _buildInputDecoration('Username')),
                const SizedBox(height: 12),

                const Text('Password', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: _buildInputDecoration('Password').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF64748B), size: 20),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                const Text('Repeat Password', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _repeatPasswordController,
                  obscureText: !_isRepeatPasswordVisible,
                  decoration: _buildInputDecoration('Repeat Password').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_isRepeatPasswordVisible ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF64748B), size: 20),
                      onPressed: () => setState(() => _isRepeatPasswordVisible = !_isRepeatPasswordVisible),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                if (_showError) _buildErrorPopup(_errorMessage),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? ", style: TextStyle(fontSize: 13)),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: const Text('Login', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, fontSize: 13)),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: 85,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.zero,
                      ),
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Signup', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      isDense: true, 
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
    );
  }

  Widget _buildErrorPopup(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
        border: const Border(left: BorderSide(color: Colors.red, width: 4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.grey, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 12))),
          GestureDetector(onTap: () => setState(() => _showError = false), child: const Icon(Icons.close, color: Colors.grey, size: 14)),
        ],
      ),
    );
  }
}
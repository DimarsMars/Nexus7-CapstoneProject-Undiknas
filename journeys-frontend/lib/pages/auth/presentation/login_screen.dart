import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:journeys/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _showError = false;
  String _errorMessage = ''; // Menambahkan variabel untuk pesan error custom

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validasi: Cek apakah field kosong
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "Email and password are required.";
        _showError = true;
      });
      return;
    }

    // Validasi: Cek apakah mengandung '@'
    if (!email.contains('@')) {
      setState(() {
        _errorMessage = "Invalid email format (must contain @)";
        _showError = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showError = false;
    });

    try {
      await _apiService.login(email, password);
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "incorrect username or password";
          _showError = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                const SizedBox(height: 40),
                Hero(
                  tag: 'app-logo',
                  child: Image.asset(
                    'assets/icons/logo.png',
                    height: 300,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Login',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Email or Username',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  decoration: _buildInputDecoration('Email or Username'),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Password',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  style: const TextStyle(color: Color(0xFF1E293B)),
                  decoration: _buildInputDecoration('Password').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: const Color(0xFF64748B),
                      ),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Menampilkan error popup dengan pesan yang dinamis
                if (_showError)
                  _buildErrorPopup(_errorMessage),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don’t have an account? "),
                    GestureDetector(
                      onTap: () => context.push('/signup'),
                      child: const Text(
                        'Signup',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Center(
                  child: SizedBox(
                    width: 85,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ),
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
      hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
    );
  }

  Widget _buildErrorPopup(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
        ],
        border: const Border(left: BorderSide(color: Colors.red, width: 4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14)),
          ),
          GestureDetector(
            onTap: () => setState(() => _showError = false),
            child: const Icon(Icons.close, color: Colors.grey, size: 16),
          ),
        ],
      ),
    );
  }
}
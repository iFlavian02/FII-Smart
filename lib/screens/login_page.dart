import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../utils/validators.dart';
import '../models/user_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false; // Add loading state
  final AuthService _auth = FirebaseAuthService();  // Inject
  final DataService _data = DataService();

  Future<void> _authAction() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!isValidEmail(email) || !isValidPassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid email or password')));
      return;
    }

    setState(() => _isLoading = true); // Start loading

    try {
      if (_isLogin) {
        await _auth.signIn(email, password);
      } else {
        await _auth.signUp(email, password);
        final uid = _auth.currentUser?.uid;
        if (uid != null) {
          await _data.updateUser(uid, UserModel());
        }
      }
      // No need to set isLoading to false here, as the StreamBuilder will navigate away
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'An error occurred')));
      setState(() => _isLoading = false); // Stop loading on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Login' : 'Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 16),
            TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 24),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(onPressed: _authAction, child: Text(_isLogin ? 'Login' : 'Sign Up')),
            if (!_isLoading)
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(_isLogin ? 'No account? Sign up' : 'Have an account? Login'),
              ),
          ],
        ),
      ),
    );
  }
}

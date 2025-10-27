import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/auth_controller.dart';

class HalamanLogin extends StatefulWidget {
  const HalamanLogin({super.key});
  @override
  State<HalamanLogin> createState() => _HalamanLoginState();
}

class _HalamanLoginState extends State<HalamanLogin> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> _doLogin() async {
    final auth = Provider.of<AuthController>(context, listen: false);

    bool sukses = await auth.attemptLogin(_email.text, _password.text);

    if (sukses && mounted) {
      String role = auth.userRole!;
      if (role == 'owner') {
        Navigator.pushReplacementNamed(context, '/owner/main');
      } else if (role == 'society') {
        Navigator.pushReplacementNamed(context, '/society/main');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Role tidak dikenali: $role')),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Login gagal')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email')),
            TextField(
              controller: _password,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: auth.isLoading ? null : _doLogin,
              child: auth.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Login'),
            ),
            TextButton(
              onPressed: auth.isLoading
                  ? null
                  : () => Navigator.pushNamed(context, '/register'),
              child: const Text('Belum punya akun? Registrasi'),
            ),
          ],
        ),
      ),
    );
  }
}
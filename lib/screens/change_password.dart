import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _errorText;
  String? _successText;

  Future<void> _changePassword() async {
    final prefs = await SharedPreferences.getInstance();
    final currentPassword = prefs.getString('note_password') ?? '';

    setState(() {
      _errorText = null;
      _successText = null;
    });

    if (_oldPasswordController.text != currentPassword) {
      setState(() {
        _errorText = 'Ancien mot de passe incorrect.';
      });
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorText = 'Les mots de passe ne correspondent pas.';
      });
      return;
    }

    if (_newPasswordController.text.length < 4) {
      setState(() {
        _errorText = 'Le mot de passe doit contenir au moins 4 caractères.';
      });
      return;
    }

    await prefs.setString('note_password', _newPasswordController.text);
    setState(() {
      _successText = 'Mot de passe changé avec succès ✅';
    });

    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Changer le mot de passe'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (_errorText != null)
              Text(_errorText!, style: const TextStyle(color: Colors.red)),
            if (_successText != null)
              Text(_successText!, style: const TextStyle(color: Colors.green)),

            const SizedBox(height: 16),
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Ancien mot de passe',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nouveau mot de passe',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmer le mot de passe',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _changePassword,
              child: const Text('Changer le mot de passe'),
            ),
          ],
        ),
      ),
    );
  }
}

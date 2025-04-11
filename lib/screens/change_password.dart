import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKeyGlobal = GlobalKey<FormState>();
  final _formKeyPrivate = GlobalKey<FormState>();

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final TextEditingController _oldPrivatePasswordController = TextEditingController();
  final TextEditingController _newPrivatePasswordController = TextEditingController();
  final TextEditingController _confirmPrivatePasswordController = TextEditingController();

  Future<void> _changePassword({required bool isPrivate}) async {
    final prefs = await SharedPreferences.getInstance();
    final oldPassword = isPrivate ? _oldPrivatePasswordController.text : _oldPasswordController.text;
    final newPassword = isPrivate ? _newPrivatePasswordController.text : _newPasswordController.text;
    final confirmPassword = isPrivate ? _confirmPrivatePasswordController.text : _confirmPasswordController.text;

    final savedPassword = prefs.getString(isPrivate ? 'private_password' : 'password') ?? '';

    if (oldPassword != savedPassword) {
      _showMessage('Ancien mot de passe incorrect', isError: true);
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage('Les mots de passe ne correspondent pas', isError: true);
      return;
    }

    await prefs.setString(isPrivate ? 'private_password' : 'password', newPassword);
    _showMessage('Mot de passe ${isPrivate ? "privé" : "global"} mis à jour avec succès');

    if (isPrivate) {
      _oldPrivatePasswordController.clear();
      _newPrivatePasswordController.clear();
      _confirmPrivatePasswordController.clear();
    } else {
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Changer les mots de passe"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text("🔒 Mot de passe global", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Form(
            key: _formKeyGlobal,
            child: Column(
              children: [
                TextFormField(
                  controller: _oldPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Ancien mot de passe'),
                ),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
                ),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirmer le mot de passe'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _changePassword(isPrivate: false),
                  child: const Text('Changer le mot de passe global'),
                ),
              ],
            ),
          ),
          const Divider(height: 40, thickness: 1.5),
          const Text("🛡️ Mot de passe des notes privées", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Form(
            key: _formKeyPrivate,
            child: Column(
              children: [
                TextFormField(
                  controller: _oldPrivatePasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Ancien mot de passe'),
                ),
                TextFormField(
                  controller: _newPrivatePasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
                ),
                TextFormField(
                  controller: _confirmPrivatePasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirmer le mot de passe'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _changePassword(isPrivate: true),
                  child: const Text('Changer le mot de passe privé'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

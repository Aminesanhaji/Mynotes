// FICHIER : lock_private_screen.dart
// Affichage d'une interface de définition et de modification du mot de passe pour les notes privées

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivatePasswordScreen extends StatefulWidget {
  const PrivatePasswordScreen({super.key});

  @override
  State<PrivatePasswordScreen> createState() => _PrivatePasswordScreenState();
}

class _PrivatePasswordScreenState extends State<PrivatePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? _currentPassword;

  @override
  void initState() {
    super.initState();
    _loadPassword();
  }

  // Récupérer le mot de passe actuel depuis SharedPreferences
  Future<void> _loadPassword() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentPassword = prefs.getString('private_password');
    });
  }

  // Sauvegarder un nouveau mot de passe
  Future<void> _savePassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('private_password', password);
  }

  // Réinitialiser le mot de passe (supprimer)
  Future<void> _resetPassword() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('private_password');
    setState(() {
      _currentPassword = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mot de passe réinitialisé.')));
  }

  // Enregistrer un nouveau mot de passe avec vérifications
  void _handleSave() {
    final old = _oldPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (_currentPassword != null && old != _currentPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ancien mot de passe incorrect.')));
      return;
    }
    if (newPass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez remplir tous les champs.')));
      return;
    }
    if (newPass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Les mots de passe ne correspondent pas.')));
      return;
    }

    _savePassword(newPass);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mot de passe mis à jour.')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mot de passe des notes privées'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_currentPassword != null)
              TextField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Ancien mot de passe'),
              ),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
            ),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirmer le mot de passe'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _handleSave, child: const Text('Enregistrer')),
            if (_currentPassword != null)
              TextButton(
                  onPressed: _resetPassword,
                  child: const Text('Réinitialiser le mot de passe')),
          ],
        ),
      ),
    );
  }
}

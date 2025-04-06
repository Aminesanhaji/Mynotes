import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'note_list.dart'; // remplace par ton vrai import

class LockScreen extends StatefulWidget {
  const LockScreen({Key? key}) : super(key: key);

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final TextEditingController _passwordController = TextEditingController();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _initializePassword();
  }

  Future<void> _initializePassword() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('note_password')) {
      // Définit un mot de passe par défaut au premier lancement (ex. : 1234)
      await prefs.setString('note_password', '1234');
    }
  }

  Future<void> _checkPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('note_password');

    if (_passwordController.text == savedPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NoteList()),
      );
    } else {
      setState(() {
        _errorText = 'Mot de passe incorrect';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Déverrouiller les notes',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  errorText: _errorText,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkPassword,
                child: const Text('Déverrouiller'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

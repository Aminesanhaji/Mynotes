import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Changer le mot de passe', style: Theme.of(context).textTheme.headlineMedium),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.deepPurple,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Mot de passe global'),
            Tab(text: 'Notes privées'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          GlobalPasswordTab(),
          PrivatePasswordTab(),
        ],
      ),
    );
  }
}

class GlobalPasswordTab extends StatefulWidget {
  const GlobalPasswordTab({super.key});

  @override
  State<GlobalPasswordTab> createState() => _GlobalPasswordTabState();
}

class _GlobalPasswordTabState extends State<GlobalPasswordTab> {
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();

  Future<void> _changePassword() async {
    final prefs = await SharedPreferences.getInstance();
    final storedPass = prefs.getString('app_password') ?? '';

    if (_currentPassController.text != storedPass) {
      _showError('Mot de passe actuel incorrect.');
      return;
    }

    await prefs.setString('app_password', _newPassController.text);
    _showSuccess('Mot de passe global mis à jour.');
    _currentPassController.clear();
    _newPassController.clear();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _currentPassController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Mot de passe actuel'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _newPassController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _changePassword,
            child: const Text('Changer le mot de passe global'),
          )
        ],
      ),
    );
  }
}

class PrivatePasswordTab extends StatefulWidget {
  const PrivatePasswordTab({Key? key}) : super(key: key);

  @override
  State<PrivatePasswordTab> createState() => _PrivatePasswordTabState();
}

class _PrivatePasswordTabState extends State<PrivatePasswordTab> {
  final _currentPrivateController = TextEditingController();
  final _newPrivateController = TextEditingController();

  Future<void> _changePrivatePassword() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('private_password') ?? '';

    if (_currentPrivateController.text != savedPassword) {
      _showError('Ancien mot de passe incorrect.');
      return;
    }

    await prefs.setString('private_password', _newPrivateController.text);
    _showSuccess('Mot de passe des notes privées mis à jour.');
    _currentPrivateController.clear();
    _newPrivateController.clear();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _currentPrivateController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Ancien mot de passe privé'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _newPrivateController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Nouveau mot de passe privé'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _changePrivatePassword,
            child: const Text('Changer le mot de passe privé'),
          )
        ],
      ),
    );
  }
}

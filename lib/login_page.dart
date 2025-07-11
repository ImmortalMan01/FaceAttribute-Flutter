import 'package:flutter/material.dart';
import 'account.dart';
import 'account_service.dart';
import 'localization.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  final void Function(Account) onLogin;
  const LoginPage({super.key, required this.onLogin});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _error = '';

  Future<void> _login() async {
    final accounts = await AccountService.getAccounts();
    final username = _usernameController.text;
    final password = _passwordController.text;
    for (final a in accounts) {
      if (a.username == username && a.password == password) {
        widget.onLogin(a);
        return;
      }
    }
    setState(() {
      _error = AppLocalizations.of(context).t('invalidLogin');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).t('login')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).t('username')),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).t('password')),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _login,
                child: Text(AppLocalizations.of(context).t('login')),
              ),
              if (_error.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(_error, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

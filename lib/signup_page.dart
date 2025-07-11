import 'package:flutter/material.dart';
import 'account.dart';
import 'account_service.dart';
import 'localization.dart';

class SignUpPage extends StatefulWidget {
  final void Function(Account) onFinished;
  const SignUpPage({super.key, required this.onFinished});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _create() async {
    final account = Account(
        username: _usernameController.text,
        password: _passwordController.text,
        isAdmin: true);
    await AccountService.insertAccount(account);
    widget.onFinished(account);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).t('createAccount')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              onPressed: _create,
              child: Text(AppLocalizations.of(context).t('createAccount')),
            )
          ],
        ),
      ),
    );
  }
}

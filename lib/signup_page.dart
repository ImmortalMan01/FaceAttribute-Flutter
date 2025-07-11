import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'account.dart';
import 'account_service.dart';
import 'localization.dart';
import 'main.dart';

class SignUpPage extends StatefulWidget {
  final void Function(Account) onFinished;
  const SignUpPage({super.key, required this.onFinished});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int _selectedLanguage = 0;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('language_code') ?? 'en';
    setState(() {
      _selectedLanguage = code == 'tr' ? 1 : 0;
    });
  }

  Future<void> _updateLanguage(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', value == 1 ? 'tr' : 'en');
    setState(() {
      _selectedLanguage = value;
    });
    MyApp.setLocale(context, Locale(value == 1 ? 'tr' : 'en'));
  }

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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButton<int>(
                    value: _selectedLanguage,
                    onChanged: (int? value) {
                      if (value != null) _updateLanguage(value);
                    },
                    items: [
                      DropdownMenuItem(
                        value: 0,
                        child: Text(AppLocalizations.of(context).t('english')),
                      ),
                      DropdownMenuItem(
                        value: 1,
                        child: Text(AppLocalizations.of(context).t('turkish')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText:
                          AppLocalizations.of(context).t('username'),
                    ),
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText:
                          AppLocalizations.of(context).t('password'),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _create,
                    child: Text(
                        AppLocalizations.of(context).t('createAccount')),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

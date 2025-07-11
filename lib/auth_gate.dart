import 'package:flutter/material.dart';
import 'account.dart';
import 'account_service.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'localization.dart';
import 'main.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;
  late bool _hasAccount;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final accounts = await AccountService.getAccounts();
    setState(() {
      _hasAccount = accounts.isNotEmpty;
      _loading = false;
    });
  }

  void _onLoggedIn(Account a) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => MyHomePage(
                  title: AppLocalizations.of(context).t('appTitle'),
                  isAdmin: a.isAdmin,
                )));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _hasAccount
        ? LoginPage(onLogin: _onLoggedIn)
        : SignUpPage(onFinished: _onLoggedIn);
  }
}

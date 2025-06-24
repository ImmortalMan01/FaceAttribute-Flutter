import 'package:flutter/material.dart';
import 'localization.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).t('aboutTitle')),
        toolbarHeight: 70,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(AppLocalizations.of(context).t('aboutContent')),
      ),
    );
  }
}

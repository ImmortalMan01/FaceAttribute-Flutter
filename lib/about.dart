import 'package:flutter/material.dart';
import 'localization.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).t('aboutTitle')),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Card(
          color: Theme.of(context).colorScheme.surfaceVariant,
          margin: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Text(AppLocalizations.of(context).t('aboutContent')),
          ),
        ),
      ),
    );
  }
}

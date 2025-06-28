import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'localization.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeumorphicAppBar(
        title: Text(AppLocalizations.of(context).t('aboutTitle')),
        toolbarHeight: 70,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Neumorphic(
          margin: const EdgeInsets.all(16.0),
          style: const NeumorphicStyle(depth: 2),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Text(AppLocalizations.of(context).t('aboutContent')),
          ),
        ),
      ),
    );
  }
}

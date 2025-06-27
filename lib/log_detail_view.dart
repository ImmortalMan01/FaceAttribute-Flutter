import 'package:flutter/material.dart';
import 'recognition_log.dart';
import 'localization.dart';

class LogDetailView extends StatelessWidget {
  final RecognitionLog log;
  const LogDetailView({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    String genderText = log.gender == 0
        ? AppLocalizations.of(context).t('male')
        : AppLocalizations.of(context).t('female');
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).t('logDetails')),
        toolbarHeight: 70,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${AppLocalizations.of(context).t('name')}${log.name}'),
              const SizedBox(height: 8),
              Text('${AppLocalizations.of(context).t('time')}${log.time}'),
              const SizedBox(height: 8),
              Text('${AppLocalizations.of(context).t('age')}${log.age}'),
              const SizedBox(height: 8),
              Text('${AppLocalizations.of(context).t('gender')}$genderText'),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'recognition_log.dart';
import 'localization.dart';

class LogDetailView extends StatelessWidget {
  final RecognitionLog log;
  const LogDetailView({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    String genderText = '';
    if (log.gender == 0) {
      genderText = AppLocalizations.of(context).t('male');
    } else if (log.gender == 1) {
      genderText = AppLocalizations.of(context).t('female');
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).t('logDetails')),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Card(
          color: Theme.of(context).colorScheme.surfaceVariant,
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(AppLocalizations.of(context).t('name')),
                  trailing: Text(log.name),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text(AppLocalizations.of(context).t('time')),
                  trailing: Text(log.formattedTime),
                ),
                if (log.age >= 0) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.cake),
                    title: Text(AppLocalizations.of(context).t('age')),
                    trailing: Text(log.age.toString()),
                  ),
                ],
                if (log.gender >= 0) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.wc),
                    title: Text(AppLocalizations.of(context).t('gender')),
                    trailing: Text(genderText),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
  );
  }
}

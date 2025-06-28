import 'package:flutter/material.dart';
import 'recognition_log.dart';
import 'localization.dart';
import 'log_detail_view.dart';

class LogView extends StatelessWidget {
  final List<RecognitionLog> logList;
  const LogView({super.key, required this.logList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).t('logs')),
        centerTitle: true,
      ),
      body: SafeArea(
        child: logList.isEmpty
            ? Center(child: Text(AppLocalizations.of(context).t('noLogs')))
            : Card(
                margin: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: logList.length,
                  itemBuilder: (context, index) {
                    final log = logList[index];
                    return ListTile(
                    title: Text(log.name),
                    subtitle: Text(log.formattedTime),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LogDetailView(log: log),
                        ),
                      );
                    },
                  );
                  },
                ),
              ),
      ),
    );
  }
}

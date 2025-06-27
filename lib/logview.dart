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
        toolbarHeight: 70,
        centerTitle: true,
      ),
      body: SafeArea(
        child: logList.isEmpty
            ? Center(child: Text(AppLocalizations.of(context).t('noLogs')))
            : ListView.builder(
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
    );
  }
}

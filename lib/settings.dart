import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'main.dart';
import 'localization.dart';
import 'about.dart';

class SettingsPage extends StatefulWidget {
  final MyHomePageState homePageState;

  const SettingsPage({super.key, required this.homePageState});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class LivenessDetectionLevel {
  String levelName;
  int levelValue;

  LivenessDetectionLevel(this.levelName, this.levelValue);
}

const double _kItemExtent = 40.0;
const List<String> _cameraLensNames = <String>['back', 'front'];
const List<String> _livenessLevelNames = <String>['best', 'light'];
const List<String> _languageNames = <String>[
  'English',
  'Türkçe',
];
const List<String> _themeNames = <String>['lightTheme', 'darkTheme', 'systemTheme'];

class SettingsPageState extends State<SettingsPage> {
  /// 0 for back camera, 1 for front camera
  int _selectedCameraLens = 1;
  String _livenessThreshold = "0.7";
  String _identifyThreshold = "0.8";
  List<LivenessDetectionLevel> livenessDetectionLevel = [
    LivenessDetectionLevel('Best Accuracy', 0),
    LivenessDetectionLevel('Light Weight', 1),
  ];
  int _selectedLivenessLevel = 0;
  int _selectedLanguage = 0;
  int _selectedTheme = 2;
  bool _estimateAgeGender = true;

  final livenessController = TextEditingController();
  final identifyController = TextEditingController();

  static Future<void> initSettings() async {
    final prefs = await SharedPreferences.getInstance();
    var firstWrite = prefs.getInt("first_write");
    if (firstWrite == 0) {
      await prefs.setInt("first_write", 1);
      await prefs.setInt("camera_lens", 1);
      await prefs.setInt("liveness_level", 0);
      await prefs.setString("liveness_threshold", "0.7");
      await prefs.setString("identify_threshold", "0.8");
      await prefs.setString("language_code", "en");
      await prefs.setBool("estimate_age_gender", true);
    }
  }

  @override
  void initState() {
    super.initState();

    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    var cameraLens = prefs.getInt("camera_lens");
    var livenessLevel = prefs.getInt("liveness_level");
    var livenessThreshold = prefs.getString("liveness_threshold");
    var identifyThreshold = prefs.getString("identify_threshold");
    var languageCode = prefs.getString("language_code");
    var estimateAgeGender = prefs.getBool("estimate_age_gender");
    var themeMode = await AdaptiveTheme.getThemeMode();

    setState(() {
      _selectedCameraLens = cameraLens ?? 1;
      _livenessThreshold = livenessThreshold ?? "0.7";
      _identifyThreshold = identifyThreshold ?? "0.8";
      _selectedLivenessLevel = livenessLevel ?? 0;
      livenessController.text = _livenessThreshold;
      identifyController.text = _identifyThreshold;
      _selectedLanguage = languageCode == 'tr' ? 1 : 0;
      _selectedTheme = themeMode == AdaptiveThemeMode.dark
          ? 1
          : themeMode == AdaptiveThemeMode.light
              ? 0
              : 2;
      _estimateAgeGender = estimateAgeGender ?? true;
    });
  }

  Future<void> restoreSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("first_write", 0);
    await initSettings();
    await loadSettings();
    await prefs.setString("language_code", "en");
    MyApp.setLocale(context, const Locale('en'));
    AdaptiveTheme.of(context).setSystem();
    setState(() {
      _selectedTheme = 2;
    });

    Fluttertoast.showToast(
        msg: AppLocalizations.of(context).t('restoreDefaults'),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future<void> updateLivenessLevel(value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("liveness_level", value);
  }

  Future<void> updateCameraLens(value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("camera_lens", value);

    setState(() {
      _selectedCameraLens = value;
    });
  }

  Future<void> updateLanguage(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("language_code", value == 1 ? 'tr' : 'en');
    setState(() {
      _selectedLanguage = value;
    });
    MyApp.setLocale(context, Locale(value == 1 ? 'tr' : 'en'));
  }

  Future<void> updateTheme(int value) async {
    setState(() {
      _selectedTheme = value;
    });
    if (value == 0) {
      AdaptiveTheme.of(context).setLight();
    } else if (value == 1) {
      AdaptiveTheme.of(context).setDark();
    } else {
      AdaptiveTheme.of(context).setSystem();
    }
  }

  Future<void> updateEstimateAgeGender(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("estimate_age_gender", value);
    setState(() {
      _estimateAgeGender = value;
    });
  }

  Future<void> updateLivenessThreshold(BuildContext context) async {
    try {
      var doubleValue = double.parse(livenessController.text);
      if (doubleValue >= 0 && doubleValue < 1.0) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("liveness_threshold", livenessController.text);

        setState(() {
          _livenessThreshold = livenessController.text;
        });
      }
    } catch (e) {}

    // ignore: use_build_context_synchronously
    Navigator.pop(context, 'OK');
    setState(() {
      livenessController.text = _livenessThreshold;
    });
  }

  Future<void> updateIdentifyThreshold(BuildContext context) async {
    try {
      var doubleValue = double.parse(identifyController.text);
      if (doubleValue >= 0 && doubleValue < 1.0) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("identify_threshold", identifyController.text);

        setState(() {
          _identifyThreshold = identifyController.text;
        });
      }
    } catch (e) {}

    // ignore: use_build_context_synchronously
    Navigator.pop(context, 'OK');
    setState(() {
      identifyController.text = _identifyThreshold;
    });
  }

// This shows a CupertinoModalPopup with a reasonable fixed height which hosts CupertinoPicker.
  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).t('settings')),
        toolbarHeight: 70,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SettingsList(
          sections: [
  SettingsSection(
            title: Text(AppLocalizations.of(context).t('cameraLens')),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                title: Text(AppLocalizations.of(context).t('cameraLens')),
                value: Text(AppLocalizations.of(context)
                    .t(_cameraLensNames[_selectedCameraLens])),
                leading: const Icon(Icons.camera),
                onPressed: (BuildContext context) => _showDialog(
                  CupertinoPicker(
                    magnification: 1.22,
                    squeeze: 1.2,
                    useMagnifier: true,
                    itemExtent: _kItemExtent,
                    scrollController: FixedExtentScrollController(
                      initialItem: _selectedCameraLens,
                    ),
                    onSelectedItemChanged: (int selectedItem) {
                      setState(() {
                        _selectedCameraLens = selectedItem;
                      });
                      updateCameraLens(selectedItem);
                    },
                    children: List<Widget>.generate(_cameraLensNames.length,
                        (int index) {
                      return Center(
                          child: Text(AppLocalizations.of(context)
                              .t(_cameraLensNames[index])));
                    }),
                  ),
                ),
              ),
            ],
          ),
          SettingsSection(
            title: Text(AppLocalizations.of(context).t('language')),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                title: Text(AppLocalizations.of(context).t('language')),
                value: Text(_languageNames[_selectedLanguage]),
                leading: const Icon(Icons.language),
                onPressed: (BuildContext context) => _showDialog(
                  CupertinoPicker(
                    magnification: 1.22,
                    squeeze: 1.2,
                    useMagnifier: true,
                    itemExtent: _kItemExtent,
                    scrollController: FixedExtentScrollController(
                      initialItem: _selectedLanguage,
                    ),
                    onSelectedItemChanged: (int selectedItem) {
                      updateLanguage(selectedItem);
                    },
                    children: List<Widget>.generate(_languageNames.length,
                        (int index) {
                      return Center(child: Text(_languageNames[index]));
                    }),
                  ),
                ),
              ),
            ],
          ),
          SettingsSection(
            title: Text(AppLocalizations.of(context).t('theme')),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                title: Text(AppLocalizations.of(context).t('theme')),
                value: Text(AppLocalizations.of(context)
                    .t(_themeNames[_selectedTheme])),
                leading: const Icon(Icons.brightness_6),
                onPressed: (BuildContext context) => _showDialog(
                  CupertinoPicker(
                    magnification: 1.22,
                    squeeze: 1.2,
                    useMagnifier: true,
                    itemExtent: _kItemExtent,
                    scrollController: FixedExtentScrollController(
                      initialItem: _selectedTheme,
                    ),
                    onSelectedItemChanged: (int selectedItem) {
                      updateTheme(selectedItem);
                    },
                    children:
                        List<Widget>.generate(_themeNames.length, (int index) {
                      return Center(
                          child: Text(AppLocalizations.of(context)
                              .t(_themeNames[index])));
                    }),
                  ),
                ),
              ),
            ],
          ),
          SettingsSection(
            title: Text(AppLocalizations.of(context).t('thresholds')),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                title: Text(AppLocalizations.of(context).t('livenessLevel')),
                value: Text(AppLocalizations.of(context)
                    .t(_livenessLevelNames[_selectedLivenessLevel])),
                leading: const Icon(Icons.person_pin_outlined),
                onPressed: (BuildContext context) => _showDialog(
                  CupertinoPicker(
                    magnification: 1.22,
                    squeeze: 1.2,
                    useMagnifier: true,
                    itemExtent: _kItemExtent,
                    // This sets the initial item.
                    scrollController: FixedExtentScrollController(
                      initialItem: _selectedLivenessLevel,
                    ),
                    // This is called when selected item is changed.
                    onSelectedItemChanged: (int selectedItem) {
                      setState(() {
                        _selectedLivenessLevel = selectedItem;
                      });
                      updateLivenessLevel(selectedItem);
                    },
                    children: List<Widget>.generate(_livenessLevelNames.length,
                        (int index) {
                      return Center(
                          child: Text(AppLocalizations.of(context)
                              .t(_livenessLevelNames[index])));
                    }),
                  ),
                ),
              ),
              SettingsTile.navigation(
                title: Text(AppLocalizations.of(context).t('livenessThreshold')),
                value: Text(_livenessThreshold),
                leading: const Icon(Icons.person_pin_outlined),
                onPressed: (BuildContext context) => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: Text(AppLocalizations.of(context).t('livenessThreshold')),
                    content: TextField(
                      controller: livenessController,
                      onChanged: (value) => {},
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                        child: Text(AppLocalizations.of(context).t('cancel')),
                      ),
                      TextButton(
                        onPressed: () => updateLivenessThreshold(context),
                        child: Text(AppLocalizations.of(context).t('ok')),
                      ),
                    ],
                  ),
                ),
              ),
              SettingsTile.navigation(
                title: Text(AppLocalizations.of(context).t('identifyThreshold')),
                leading: const Icon(Icons.person_search),
                value: Text(_identifyThreshold),
                onPressed: (BuildContext context) => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: Text(AppLocalizations.of(context).t('identifyThreshold')),
                    content: TextField(
                      controller: identifyController,
                      onChanged: (value) => {},
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                        child: Text(AppLocalizations.of(context).t('cancel')),
                      ),
                      TextButton(
                        onPressed: () => updateIdentifyThreshold(context),
                        child: Text(AppLocalizations.of(context).t('ok')),
                      ),
                    ],
                  ),
                ),
              ),
              SettingsTile.switchTile(
                title:
                    Text(AppLocalizations.of(context).t('estimateAgeGender')),
                leading: const Icon(Icons.person_outline),
                initialValue: _estimateAgeGender,
                onToggle: (value) => updateEstimateAgeGender(value),
              ),
            ],
          ),
          SettingsSection(
            title: Text(AppLocalizations.of(context).t('reset')),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                title: Text(AppLocalizations.of(context).t('restoreDefaults')),
                leading: const Icon(Icons.restore),
                onPressed: (BuildContext context) => restoreSettings(),
              ),
              SettingsTile.navigation(
                title: Text(AppLocalizations.of(context).t('clearAllPerson')),
                leading: const Icon(Icons.clear_all),
                onPressed: (BuildContext context) {
                  widget.homePageState.deleteAllPerson();
                },
              ),
            ],
          ),
          SettingsSection(
            title: Text(AppLocalizations.of(context).t('about')),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                title: Text(AppLocalizations.of(context).t('about')),
                leading: const Icon(Icons.info),
                onPressed: (BuildContext context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AboutPage()),
                  );
                },
              ),
            ],
          ),
          ],
        ),
      ),
    );
  }
}

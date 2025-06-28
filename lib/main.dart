// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';
import 'package:facesdk_plugin/facesdk_plugin.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'dart:io' show Platform;
import 'about.dart';
import 'settings.dart';
import 'person.dart';
import 'personview.dart';
import 'facedetectionview.dart';
import 'facecaptureview.dart';
import 'logview.dart';
import 'recognition_log.dart';
import 'localization.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AdaptiveThemeMode? savedThemeMode;
  try {
    savedThemeMode = await AdaptiveTheme.getThemeMode();
  } catch (_) {
    savedThemeMode = AdaptiveThemeMode.system;
  }
  runApp(MyApp(savedThemeMode: savedThemeMode));
}

class MyApp extends StatefulWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({super.key, this.savedThemeMode});

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String code = prefs.getString('language_code') ?? 'en';
    setState(() {
      _locale = Locale(code);
    });
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF6750A4);
    final lightScheme = ColorScheme.fromSeed(seedColor: seedColor).copyWith(
      surface: const Color(0xFFFFFFFF),
      background: const Color(0xFFF6F3FF),
    );
    final darkScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    ).copyWith(
      surface: const Color(0xFF1E1B24),
      background: const Color(0xFF141218),
    );

    return AdaptiveTheme(
      light: ThemeData(
        useMaterial3: true,
        colorScheme: lightScheme,
      ),
      dark: ThemeData(
        useMaterial3: true,
        colorScheme: darkScheme,
      ),
      initial: widget.savedThemeMode ?? AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => Builder(
            builder: (context) => NeumorphicApp(
                locale: _locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                title: AppLocalizations(_locale).t('appTitle'),
                materialTheme: theme,
                materialDarkTheme: darkTheme,
                theme: NeumorphicThemeData(
                  baseColor: theme.colorScheme.background,
                  accentColor: theme.colorScheme.primary,
                  variantColor: theme.colorScheme.secondary,
                  lightSource: LightSource.topLeft,
                ),
                darkTheme: NeumorphicThemeData(
                  baseColor: darkTheme.colorScheme.background,
                  accentColor: darkTheme.colorScheme.primary,
                  variantColor: darkTheme.colorScheme.secondary,
                  lightSource: LightSource.topLeft,
                ),
                themeMode: AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark
                    ? ThemeMode.dark
                    : AdaptiveTheme.of(context).mode == AdaptiveThemeMode.light
                        ? ThemeMode.light
                        : ThemeMode.system,
                home:
                    MyHomePage(title: AppLocalizations(_locale).t('appTitle')))),
    );
  }
}

// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({super.key, required this.title});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  String _warningState = "";
  bool _visibleWarning = false;
  bool _initializing = true;

  List<Person> personList = [];
  List<RecognitionLog> logList = [];

  final _facesdkPlugin = FacesdkPlugin();

  ButtonStyle _buttonStyle(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 12),
      backgroundColor: scheme.primaryContainer,
      foregroundColor: scheme.onPrimaryContainer,
      shape: const StadiumBorder(),
    );
  }

  @override
  void initState() {
    super.initState();
    // Delay heavy initialization until after the first frame so that
    // the UI can render without blocking on native plugin calls.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await init();
      } finally {
        if (mounted) {
          setState(() {
            _initializing = false;
          });
        }
      }
    });
  }

  Future<void> init() async {
    int facepluginState = -1;
    String warningState = "";
    bool visibleWarning = false;
    List<Person> personList = [];
    List<RecognitionLog> logList = [];

    try {
      if (!Platform.isAndroid && !Platform.isIOS) {
        setState(() {
          _warningState =
              AppLocalizations.of(context).t('unsupportedPlatform');
          _visibleWarning = true;
        });
        return;
      } else if (Platform.isAndroid) {
        await _facesdkPlugin
            .setActivation(
                "jmmEAcBHenipyeBgRVbnncSD905Yqv5ooWGF6OIBaJVbHveX9cxtLFSOFK6lM0530bHYEKeq4lax"
                "AotSJ08XN19t9YgBlAK3DX556BhAdjLK0cNrqp4xgV0szHh8UL1TbGGoIRQsq7cRDJHH/oqVLh1+"
                "Lo64nz7HMPqicL0YgEPlIfcOm+SAhj6hPXsav0F87V88YyWDlmlaw07PROXkjI2YlHhyfQ+ANXhx"
                "3aAqVfDi+SO0xwa9W405IfQ0t7hThWc/MxilEgr2+LNEOM/NnWmUOvbVKsK9RokUWyY2bDJjiJ9B"
                "GmhjIqDnNTbHTONh6ZNcWpZBbYt3jmSWXls7Mg==")
            .then((value) => facepluginState = value ?? -1);
      } else if (Platform.isIOS) {
        facepluginState = await _facesdkPlugin.setActivation(
            "mCl744lTkL7Dz3MZr2/oCwS0H5g9L8Fl6IiB/2EZ8Gz37x9rP8rnW/E1FKauvJdAEly2v6jiESZa"
            "p1OT99zvcvlZ9uI0COOrDVg9e1ytM4/6AJru4i5iSybtW3P7rRkGycFikDBxRzPytTJRuqLQuQ9r"
            "XbiiBfcN/kvgEXpY3o1r7mAQbB9wpSdrL+xeXhl86mTTo7BAoyzphfYdVd6n0l3suZSiMYMpt9t7"
            "U5AU3CaiJW7iTbibVXjp9F60D32M4/LRlontvqJfK8s2PqI5w3Eam0ElXxfP5aQTXuh0aZ/XMp7g"
            "NrR7GECzigNCg/vameeobUPkVd9OFk+lgQpVeg==") ??
            -1;
      }

      if (facepluginState == 0) {
        facepluginState = await _facesdkPlugin.init() ?? -1;
      }

      personList = await loadAllPersons();
      logList = await loadAllLogs();
      await SettingsPageState.initSettings();

      final prefs = await SharedPreferences.getInstance();
      int? livenessLevel = prefs.getInt("liveness_level");
      bool? estimateAgeGender = prefs.getBool("estimate_age_gender");

      await _facesdkPlugin.setParam({
        'check_liveness_level': livenessLevel ?? 0,
        'check_eye_closeness': true,
        'check_face_occlusion': true,
        'check_mouth_opened': true,
        'estimate_age_gender': estimateAgeGender ?? true
      });
    } catch (e) {
      warningState = e.toString();
      visibleWarning = true;
    }

    if (!mounted) return;

    if (warningState.isEmpty) {
      if (facepluginState == -1) {
        warningState = AppLocalizations.of(context).t('invalidLicense');
        visibleWarning = true;
      } else if (facepluginState == -2) {
        warningState = AppLocalizations.of(context).t('licenseExpired');
        visibleWarning = true;
      } else if (facepluginState == -3) {
        warningState = AppLocalizations.of(context).t('invalidLicense');
        visibleWarning = true;
      } else if (facepluginState == -4) {
        warningState = AppLocalizations.of(context).t('noActivated');
        visibleWarning = true;
      } else if (facepluginState == -5) {
        warningState = AppLocalizations.of(context).t('initError');
        visibleWarning = true;
      }
    }

    setState(() {
      _warningState = warningState;
      _visibleWarning = visibleWarning;
      this.personList = personList;
      this.logList = logList;
    });
  }

  Future<Database> createDB() async {
    final database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      p.join(await getDatabasesPath(), 'person.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          'CREATE TABLE person(name text, faceJpg blob, templates blob)',
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );

    return database;
  }

  Future<Database> createLogDB() async {
    final database = openDatabase(
      p.join(await getDatabasesPath(), 'log.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE log(id INTEGER PRIMARY KEY AUTOINCREMENT, name text, time text, age INTEGER, gender INTEGER)');
      },
      version: 1,
    );

    return database;
  }

  // A method that retrieves all the dogs from the dogs table.
  Future<List<Person>> loadAllPersons() async {
    // Get a reference to the database.
    final db = await createDB();

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('person');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Person.fromMap(maps[i]);
    });
  }

  Future<List<RecognitionLog>> loadAllLogs() async {
    final db = await createLogDB();

    final List<Map<String, dynamic>> maps =
        await db.query('log', orderBy: 'id DESC');

    return List.generate(maps.length, (i) {
      return RecognitionLog.fromMap(maps[i]);
    });
  }

  Future<void> insertLog(RecognitionLog log) async {
    final db = await createLogDB();

    await db.insert('log', log.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    setState(() {
      logList.insert(0, log);
    });
  }

  Future<void> insertPerson(Person person) async {
    // Get a reference to the database.
    final db = await createDB();

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'person',
      person.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    setState(() {
      personList.add(person);
    });
  }

  Future<void> deleteAllPerson() async {
    final db = await createDB();
    await db.delete('person');

    setState(() {
      personList.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppLocalizations.of(context).t('allPersonDeleted'),
          style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer)),
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      duration: const Duration(seconds: 1),
    ));
  }

  Future<void> deletePerson(index) async {
    // ignore: invalid_use_of_protected_member

    final db = await createDB();
    await db.delete('person',
        where: 'name=?', whereArgs: [personList[index].name]);

    // ignore: invalid_use_of_protected_member
    setState(() {
      personList.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppLocalizations.of(context).t('personRemoved'),
          style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer)),
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      duration: const Duration(seconds: 1),
    ));
  }

  Future<void> updatePersonName(int index, String newName) async {
    final db = await createDB();
    await db.update('person', {'name': newName},
        where: 'name=?', whereArgs: [personList[index].name]);

    setState(() {
      personList[index] = Person(
          name: newName,
          faceJpg: personList[index].faceJpg,
          templates: personList[index].templates);
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppLocalizations.of(context).t('personRenamed'),
          style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer)),
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      duration: const Duration(seconds: 1),
    ));
  }

  Future<String?> requestPersonName() async {
    return _requestPersonName();
  }

  Future<String?> _requestPersonName() async {
    TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).t('enterName')),
          content: TextField(
            controller: controller,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).t('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(AppLocalizations.of(context).t('ok')),
            )
          ],
        );
      },
    );
  }

  Future enrollPerson() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      var rotatedImage =
          await FlutterExifRotation.rotateImage(path: image.path);

      final faces = await _facesdkPlugin.extractFaces(rotatedImage.path);
      for (var face in faces) {
        final name = await _requestPersonName();
        if (name == null || name.isEmpty) {
          continue;
        }
        Person person = Person(
            name: name,
            faceJpg: face['faceJpg'],
            templates: face['templates']);
        insertPerson(person);
      }

      if (faces.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).t('noFaceDetected'),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer)),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          duration: const Duration(seconds: 1),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).t('personEnrolled'),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer)),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          duration: const Duration(seconds: 1),
        ));
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).t('appTitle')),
      ),
      body: SafeArea(
        child: Container(
        margin: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: Column(
          children: <Widget>[
            Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ListTile(
                    leading: const Icon(Icons.tips_and_updates),
                    subtitle: Text(
                      AppLocalizations.of(context).t('subtitle'),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                )),
            const SizedBox(
              height: 6,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: FilledButton(
                      style: _buttonStyle(context),
                      onPressed: enrollPerson,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_add,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context).t('enroll'),
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer)),
                        ],
                      )),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: FilledButton(
                      style: _buttonStyle(context),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FaceRecognitionView(
                                    personList: personList,
                                    addLog: insertLog,
                                  )),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_search,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context).t('identify'),
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer)),
                        ],
                      )),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: FilledButton(
                      style: _buttonStyle(context),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsPage(
                                    homePageState: this,
                                  )),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.settings,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context).t('settings'),
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer)),
                        ],
                      )),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: FilledButton(
                      style: _buttonStyle(context),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FaceCaptureView(
                                    personList: personList,
                                    insertPerson: insertPerson,
                                  )),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_pin,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context).t('capture'),
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer)),
                        ],
                      )),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton(
                      style: _buttonStyle(context),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LogView(
                                    logList: logList,
                                  )),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.list,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context).t('logs'),
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer)),
                        ],
                      )),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Expanded(
                child: Stack(
              children: [
                PersonView(
                  personList: personList,
                  homePageState: this,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Visibility(
                        visible: _visibleWarning,
                        child: Container(
                          width: double.infinity,
                          height: 40,
                          color:
                              Theme.of(context).colorScheme.errorContainer,
                          child: Center(
                            child: Text(
                              _warningState,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onErrorContainer),
                            ),
                          ),
                        ))
                  ],
                )
              ],
            )),
            const SizedBox(
              height: 4,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage('assets/ic_kby.png'),
                  height: 32,
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    ));
  }
}

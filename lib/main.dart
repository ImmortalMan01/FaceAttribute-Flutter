// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';
import 'package:facesdk_plugin/facesdk_plugin.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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
    return MaterialApp(
        locale: _locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        title: AppLocalizations(_locale).t('appTitle'),
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        home: MyHomePage(title: AppLocalizations(_locale).t('appTitle')));
  }
}

// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  final String title;
  var personList = <Person>[];
  var logList = <RecognitionLog>[];

  MyHomePage({super.key, required this.title});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  String _warningState = "";
  bool _visibleWarning = false;

  final _facesdkPlugin = FacesdkPlugin();

  @override
  void initState() {
    super.initState();

    init();
  }

  Future<void> init() async {
    int facepluginState = -1;
    String warningState = "";
    bool visibleWarning = false;

    try {
      if (Platform.isAndroid) {
        await _facesdkPlugin
            .setActivation(
                "jmmEAcBHenipyeBgRVbnncSD905Yqv5ooWGF6OIBaJVbHveX9cxtLFSOFK6lM0530bHYEKeq4lax"
                "AotSJ08XN19t9YgBlAK3DX556BhAdjLK0cNrqp4xgV0szHh8UL1TbGGoIRQsq7cRDJHH/oqVLh1+"
                "Lo64nz7HMPqicL0YgEPlIfcOm+SAhj6hPXsav0F87V88YyWDlmlaw07PROXkjI2YlHhyfQ+ANXhx"
                "3aAqVfDi+SO0xwa9W405IfQ0t7hThWc/MxilEgr2+LNEOM/NnWmUOvbVKsK9RokUWyY2bDJjiJ9B"
                "GmhjIqDnNTbHTONh6ZNcWpZBbYt3jmSWXls7Mg==")
            .then((value) => facepluginState = value ?? -1);
      } else {
        await _facesdkPlugin
            .setActivation(
                "mCl744lTkL7Dz3MZr2/oCwS0H5g9L8Fl6IiB/2EZ8Gz37x9rP8rnW/E1FKauvJdAEly2v6jiESZa"
                "p1OT99zvcvlZ9uI0COOrDVg9e1ytM4/6AJru4i5iSybtW3P7rRkGycFikDBxRzPytTJRuqLQuQ9r"
                "XbiiBfcN/kvgEXpY3o1r7mAQbB9wpSdrL+xeXhl86mTTo7BAoyzphfYdVd6n0l3suZSiMYMpt9t7"
                "U5AU3CaiJW7iTbibVXjp9F60D32M4/LRlontvqJfK8s2PqI5w3Eam0ElXxfP5aQTXuh0aZ/XMp7g"
                "NrR7GECzigNCg/vameeobUPkVd9OFk+lgQpVeg==")
            .then((value) => facepluginState = value ?? -1);
      }

      if (facepluginState == 0) {
        await _facesdkPlugin
            .init()
            .then((value) => facepluginState = value ?? -1);
      }
    } catch (e) {}

    List<Person> personList = await loadAllPersons();
    List<RecognitionLog> logList = await loadAllLogs();
    await SettingsPageState.initSettings();

    final prefs = await SharedPreferences.getInstance();
    int? livenessLevel = prefs.getInt("liveness_level");

    try {
      await _facesdkPlugin.setParam({
        'check_liveness_level': livenessLevel ?? 0,
        'check_eye_closeness': true,
        'check_face_occlusion': true,
        'check_mouth_opened': true,
        'estimate_age_gender': true
      });
    } catch (e) {}

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

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

    setState(() {
      _warningState = warningState;
      _visibleWarning = visibleWarning;
      widget.personList = personList;
      widget.logList = logList;
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
      widget.logList.insert(0, log);
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
      widget.personList.add(person);
    });
  }

  Future<void> deleteAllPerson() async {
    final db = await createDB();
    await db.delete('person');

    setState(() {
      widget.personList.clear();
    });

    Fluttertoast.showToast(
        msg: AppLocalizations.of(context).t('allPersonDeleted'),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future<void> deletePerson(index) async {
    // ignore: invalid_use_of_protected_member

    final db = await createDB();
    await db.delete('person',
        where: 'name=?', whereArgs: [widget.personList[index].name]);

    // ignore: invalid_use_of_protected_member
    setState(() {
      widget.personList.removeAt(index);
    });

    Fluttertoast.showToast(
        msg: AppLocalizations.of(context).t('personRemoved'),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
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

      if (faces.length == 0) {
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context).t('noFaceDetected'),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context).t('personEnrolled'),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).t('appTitle')),
        toolbarHeight: 70,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
        margin: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: Column(
          children: <Widget>[
            Card(
                color: Color.fromARGB(255, 0x49, 0x45, 0x4F),
                child: ListTile(
                  leading: Icon(Icons.tips_and_updates),
                  subtitle: Text(
                    AppLocalizations.of(context).t('subtitle'),
                    style: const TextStyle(fontSize: 13),
                  ),
                )),
            const SizedBox(
              height: 6,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: ElevatedButton.icon(
                      label: Text(AppLocalizations.of(context).t('enroll')),
                      icon: const Icon(
                        Icons.person_add,
                        // color: Colors.white70,
                      ),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          // foregroundColor: Colors.white70,
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          )),
                      onPressed: enrollPerson),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: ElevatedButton.icon(
                      label: Text(AppLocalizations.of(context).t('identify')),
                      icon: const Icon(
                        Icons.person_search,
                      ),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          )),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FaceRecognitionView(
                                    personList: widget.personList,
                                    addLog: insertLog,
                                  )),
                        );
                      }),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: ElevatedButton.icon(
                      label: Text(AppLocalizations.of(context).t('settings')),
                      icon: const Icon(
                        Icons.settings,
                      ),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          )),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsPage(
                                    homePageState: this,
                                  )),
                        );
                      }),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: ElevatedButton.icon(
                      label: Text(AppLocalizations.of(context).t('capture')),
                      icon: const Icon(
                        Icons.person_pin,
                      ),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          )),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FaceCaptureView(
                                    personList: widget.personList,
                                    insertPerson: insertPerson,
                                  )),
                        );
                      }),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton.icon(
                      label: Text(AppLocalizations.of(context).t('logs')),
                      icon: const Icon(
                        Icons.list,
                      ),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          )),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LogView(
                                    logList: widget.logList,
                                  )),
                        );
                      }),
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
                  personList: widget.personList,
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
                          color: Colors.redAccent,
                          child: Center(
                            child: Text(
                              _warningState,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 20),
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

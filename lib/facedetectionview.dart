import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:facesdk_plugin/facedetection_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'facesdk_plugin_import.dart';
import 'logger.dart';
import 'person.dart';
import 'recognition_log.dart';
import 'localization.dart';
import 'relay_service.dart';
import 'ble_notification_service.dart';

// ignore: must_be_immutable
class FaceRecognitionView extends StatefulWidget {
  final List<Person> personList;
  final Function(RecognitionLog) addLog;
  FaceDetectionViewController? faceDetectionViewController;

  FaceRecognitionView({super.key, required this.personList, required this.addLog});

  @override
  State<StatefulWidget> createState() => FaceRecognitionViewState();
}

class FaceRecognitionViewState extends State<FaceRecognitionView> {
  dynamic _faces;
  double _livenessThreshold = 0;
  double _identifyThreshold = 0;
  bool _recognized = false;
  String _identifiedName = "";
  String _identifiedSimilarity = "";
  String _identifiedLiveness = "";
  String _identifiedYaw = "";
  String _identifiedRoll = "";
  String _identifiedPitch = "";
  String _identifiedAge = "";
  String _identifiedGender = "";
  bool _estimateAgeGender = true;
  // ignore: prefer_typing_uninitialized_variables
  var _identifiedFace;
  // ignore: prefer_typing_uninitialized_variables
  var _enrolledFace;
  final _facesdkPlugin = FacesdkPlugin();
  final RelayService _relayService = RelayService();
  FaceDetectionViewController? faceDetectionViewController;

  @override
  void initState() {
    super.initState();

    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    String? livenessThreshold = prefs.getString("liveness_threshold");
    String? identifyThreshold = prefs.getString("identify_threshold");
    bool? estimateAgeGender = prefs.getBool("estimate_age_gender");
    setState(() {
      _livenessThreshold = double.parse(livenessThreshold ?? "0.7");
      _identifyThreshold = double.parse(identifyThreshold ?? "0.8");
      _estimateAgeGender = estimateAgeGender ?? true;
    });
  }

  Future<void> faceRecognitionStart() async {
    final prefs = await SharedPreferences.getInstance();
    var cameraLens = prefs.getInt("camera_lens");

    setState(() {
      _faces = null;
      _recognized = false;
    });

    await faceDetectionViewController?.startCamera(cameraLens ?? 1);
  }

  Future<bool> onFaceDetected(faces) async {
    if (_recognized == true) {
      return false;
    }

    if (!mounted) return false;

    setState(() {
      _faces = faces;
    });

    bool recognized = false;
    double maxSimilarity = -1;
    String maxSimilarityName = "";
    double maxLiveness = -1;
    double maxYaw = -1;
    double maxRoll = -1;
    double maxPitch = -1;
    int maxAge = -1;
    int maxGender = -1;
    // ignore: prefer_typing_uninitialized_variables
    var enrolledFace, identifedFace;
    if (faces.length > 0) {
      var face = faces[0];
      AppLogger.d('x1: ' + face['x1'].toString() + ', y1: ' + face['y1'].toString() + ', x2: ' + face['x2'].toString() + ', y2: ' + face['y2'].toString());
      AppLogger.d('liveness: ' + face['liveness'].toString());
      AppLogger.d('yaw: ' + face['yaw'].toString());
      AppLogger.d('roll: ' + face['roll'].toString());
      AppLogger.d('pitch: ' + face['pitch'].toString());
      AppLogger.d('face_quality: ' + face['face_quality'].toString());
      AppLogger.d('face_luminance: ' + face['face_luminance'].toString());
      AppLogger.d('left_eye_closed: ' + face['left_eye_closed'].toString());
      AppLogger.d('right_eye_closed: ' + face['right_eye_closed'].toString());
      AppLogger.d('face_occlusion: ' + face['face_occlusion'].toString());
      AppLogger.d('mouth_opened: ' + face['mouth_opened'].toString());
      if (_estimateAgeGender) {
        AppLogger.d('age: ' + face['age'].toString());
        AppLogger.d('gender: ' + face['gender'].toString());
      }

      for (var person in widget.personList) {
        double similarity = await _facesdkPlugin.similarityCalculation(
                face['templates'], person.templates) ??
            -1;
        if (maxSimilarity < similarity) {
          maxSimilarity = similarity;
          maxSimilarityName = person.name;
          maxLiveness = face['liveness'];
          maxYaw = face['yaw'];
          maxRoll = face['roll'];
          maxPitch = face['pitch'];
          if (_estimateAgeGender) {
            maxAge = face['age'];
            maxGender = face['gender'];
          }
          identifedFace = face['faceJpg'];
          enrolledFace = person.faceJpg;
        }
      }

      if (maxSimilarity > _identifyThreshold && maxLiveness > _livenessThreshold) {
        recognized = true;
      }
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return false;
      setState(() {
        _recognized = recognized;
        _identifiedName = maxSimilarityName;
        _identifiedSimilarity = maxSimilarity.toString();
        _identifiedLiveness = maxLiveness.toString();
        _identifiedYaw = maxYaw.toString();
        _identifiedRoll = maxRoll.toString();
        _identifiedPitch = maxPitch.toString();
        _identifiedAge = _estimateAgeGender ? maxAge.toString() : '';
        _identifiedGender = _estimateAgeGender
            ? (maxGender == 0
                ? AppLocalizations.of(context).t('male')
                : AppLocalizations.of(context).t('female'))
            : '';
        _enrolledFace = enrolledFace;
        _identifiedFace = identifedFace;
      });
      if (recognized) {
        widget.addLog(RecognitionLog(
            name: maxSimilarityName,
            time: DateTime.now().toIso8601String(),
            age: _estimateAgeGender ? maxAge : -1,
            gender: _estimateAgeGender ? maxGender : -1));
        unawaited(_relayService.sendRelay(1, true));
        unawaited(BleNotificationService.instance.broadcastName(maxSimilarityName));
        faceDetectionViewController?.stopCamera();
        setState(() {
          _faces = null;
        });
      }
    });

    return recognized;
  }

  @override
  Widget build(BuildContext context) {
    final double imageSize =
        MediaQuery.of(context).size.shortestSide * 0.3;
    return WillPopScope(
      onWillPop: () async {
        faceDetectionViewController?.stopCamera();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).t('appTitle')),
          toolbarHeight: 70,
          centerTitle: true,
        ),
        body: SafeArea(
          child: OrientationBuilder(builder: (context, orientation) {
            final quarterTurns = orientation == Orientation.portrait ? 1 : 0;
            return Stack(children: <Widget>[
              RotatedBox(
                quarterTurns: quarterTurns,
                child: FaceDetectionView(faceRecognitionViewState: this),
              ),
              RotatedBox(
                quarterTurns: quarterTurns,
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: CustomPaint(
                    painter: FacePainter(
                        faces: _faces, livenessThreshold: _livenessThreshold),
                  ),
                ),
              ),
            Visibility(
                visible: _recognized,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Theme.of(context).colorScheme.background,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            _enrolledFace != null
                                ? Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.memory(
                                          _enrolledFace,
                                          width: imageSize,
                                          height: imageSize,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(AppLocalizations.of(context).t('enrolled'))
                                    ],
                                  )
                                : const SizedBox(
                                    height: 1,
                                  ),
                            _identifiedFace != null
                                ? Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.memory(
                                          _identifiedFace,
                                          width: imageSize,
                                          height: imageSize,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(AppLocalizations.of(context).t('identified'))
                                    ],
                                  )
                                : const SizedBox(
                                    height: 1,
                                  )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 16,
                            ),
                            Text(
                              AppLocalizations.of(context).t('identifiedName') +
                                  _identifiedName,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 16,
                            ),
                            Text(
                              AppLocalizations.of(context).t('similarity') +
                                  _identifiedSimilarity,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 16,
                            ),
                            Text(
                              AppLocalizations.of(context).t('livenessScore') +
                                  _identifiedLiveness,
                              style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onBackground),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 16,
                            ),
                            Text(
                              AppLocalizations.of(context).t('yaw') +
                                  _identifiedYaw,
                              style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onBackground),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 16,
                            ),
                            Text(
                              AppLocalizations.of(context).t('roll') +
                                  _identifiedRoll,
                              style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onBackground),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 16,
                            ),
                            Text(
                              AppLocalizations.of(context).t('pitch') +
                                  _identifiedPitch,
                              style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onBackground),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Visibility(
                          visible: _estimateAgeGender,
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 16,
                              ),
                              Text(
                                AppLocalizations.of(context).t('age') +
                                    _identifiedAge,
                                style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onBackground),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Visibility(
                          visible: _estimateAgeGender,
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 16,
                              ),
                              Text(
                                AppLocalizations.of(context).t('gender') +
                                    _identifiedGender,
                                style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onBackground),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                          onPressed: () => faceRecognitionStart(),
                          child: Text(AppLocalizations.of(context).t('tryAgain')),
                        ),
                      ]),
                )),
              ]);
            }),
          ),
        ),
    ); // Close WillPopScope
    
  }
}

class FaceDetectionView extends StatefulWidget
    implements FaceDetectionInterface {
  FaceRecognitionViewState faceRecognitionViewState;

  FaceDetectionView({super.key, required this.faceRecognitionViewState});

  @override
  Future<void> onFaceDetected(faces) async {
    await faceRecognitionViewState.onFaceDetected(faces);
  }

  @override
  State<StatefulWidget> createState() => _FaceDetectionViewState();
}

class _FaceDetectionViewState extends State<FaceDetectionView> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'facedetectionview',
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else {
      return UiKitView(
        viewType: 'facedetectionview',
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
  }

  void _onPlatformViewCreated(int id) async {
    final prefs = await SharedPreferences.getInstance();
    var cameraLens = prefs.getInt("camera_lens");

    widget.faceRecognitionViewState.faceDetectionViewController =
        FaceDetectionViewController(id, widget);

    await widget.faceRecognitionViewState.faceDetectionViewController
        ?.initHandler();

    int? livenessLevel = prefs.getInt("liveness_level");
    bool? estimateAgeGender = prefs.getBool("estimate_age_gender");
    await widget.faceRecognitionViewState._facesdkPlugin.setParam({
      'check_liveness_level': livenessLevel ?? 0,
      'check_eye_closeness': true,
      'check_face_occlusion': true,
      'check_mouth_opened': true,
      'estimate_age_gender': estimateAgeGender ?? true
    });

    await widget.faceRecognitionViewState.faceDetectionViewController
        ?.startCamera(cameraLens ?? 1);
  }
}

class FacePainter extends CustomPainter {
  dynamic faces;
  double livenessThreshold;
  FacePainter({required this.faces, required this.livenessThreshold});

  @override
  void paint(Canvas canvas, Size size) {
    if (faces != null) {
      var paint = Paint();
      paint.color = const Color.fromARGB(0xff, 0xff, 0, 0);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 3;

      for (var face in faces) {
        double xScale = face['frameWidth'] / size.width;
        double yScale = face['frameHeight'] / size.height;

        String title = "";
        Color color = const Color.fromARGB(0xff, 0xff, 0, 0);
        if (face['liveness'] < livenessThreshold) {
          color = const Color.fromARGB(0xff, 0xff, 0, 0);
          title = "Spoof" + face['liveness'].toString();
        } else {
          color = const Color.fromARGB(0xff, 0, 0xff, 0);
          title = "Real " + face['liveness'].toString();
        }

        TextSpan span =
            TextSpan(style: TextStyle(color: color, fontSize: 20), text: title);
        TextPainter tp = TextPainter(
            text: span,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, Offset(face['x1'] / xScale, face['y1'] / yScale - 30));

        paint.color = color;
        canvas.drawRect(
            Offset(face['x1'] / xScale, face['y1'] / yScale) &
                Size((face['x2'] - face['x1']) / xScale,
                    (face['y2'] - face['y1']) / yScale),
            paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

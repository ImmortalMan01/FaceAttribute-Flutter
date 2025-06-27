import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:onnxruntime/onnxruntime.dart';

class InsightFaceAgeEstimator {
  InsightFaceAgeEstimator._();
  static final InsightFaceAgeEstimator instance = InsightFaceAgeEstimator._();

  OrtSession? _session;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    OrtEnv.instance.init();
    final sessionOptions = OrtSessionOptions();
    final raw = await rootBundle.load('assets/genderage.onnx');
    _session = OrtSession.fromBuffer(raw.buffer.asUint8List(), sessionOptions);
    sessionOptions.release();
    _initialized = true;
  }

  Future<int> estimateAge(Uint8List imageBytes) async {
    await init();
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Invalid image bytes');
    }
    const inputSize = 96;
    final resized = img.copyResize(image, width: inputSize, height: inputSize);

    final buffer = Float32List(inputSize * inputSize * 3);
    var index = 0;
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resized.getPixel(x, y);
        // The image package returns a Pixel object with r, g, b getters.
        buffer[index++] = pixel.b.toDouble();
        buffer[index++] = pixel.g.toDouble();
        buffer[index++] = pixel.r.toDouble();
      }
    }

    final inputTensor =
        OrtValueTensor.createTensorWithDataList(buffer, [1, 3, inputSize, inputSize]);
    final outputs = _session!.run(OrtRunOptions(), {'data': inputTensor});
    final List<double> result =
        (outputs.first!.value as List<dynamic>).cast<double>();
    inputTensor.release();
    outputs.forEach((e) => e?.release());

    final age = (result[2] * 100).round();
    return age;
  }

  void dispose() {
    _session?.release();
    _session = null;
    if (_initialized) {
      OrtEnv.instance.release();
      _initialized = false;
    }
  }
}

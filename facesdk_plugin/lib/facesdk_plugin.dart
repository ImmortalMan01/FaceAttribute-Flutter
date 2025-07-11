import 'dart:typed_data';

import 'facesdk_plugin_platform_interface.dart';

class FacesdkPlugin {
  Future<String?> getPlatformVersion() {
    return FacesdkPluginPlatform.instance.getPlatformVersion();
  }

  /// Activation is no longer required. This method is kept for backwards
  /// compatibility and always returns success.
  Future<int?> setActivation([String? license]) async {
    try {
      return await FacesdkPluginPlatform.instance.setActivation(license ?? '');
    } catch (_) {
      // Ignore any activation errors.
      return 0;
    }
  }

  Future<int?> init() {
    return FacesdkPluginPlatform.instance.init();
  }

  Future<void> setParam(Map<String, Object> params) async {
    await FacesdkPluginPlatform.instance.setParam(params);
  }

  Future<dynamic> extractFaces(String imagePath) {
    return FacesdkPluginPlatform.instance.extractFaces(imagePath);
  }

  Future<double?> similarityCalculation(
      Uint8List templates1, Uint8List templates2) {
    return FacesdkPluginPlatform.instance
        .similarityCalculation(templates1, templates2);
  }
}

part of super_camera;

enum CameraApi { android, iOS, supportAndroid }
enum LensDirection { front, back, external }

abstract class CameraDescription {
  LensDirection get direction;
  dynamic get id;
}

class CameraController {
  CameraController._({
    @required this.description,
    @required this.controller,
    @required this.api,
  })  : assert(description != null),
        assert(controller != null),
        assert(api != null);

  factory CameraController({CameraDescription description}) {
    return CameraController._(
      description: description,
      controller: _createDefaultConfig(description),
      api: _getCameraApi(description),
    );
  }

  final CameraDescription description;
  final CameraController controller;
  final CameraApi api;

  int get previewTextureId => controller.previewTextureId;
  Future<void> start() => controller.start();
  Future<void> stop() => controller.stop();
  Future<void> dispose() => controller.dispose();
  Future<void> addPreviewTexture() => controller.addPreviewTexture();

  static CameraController _createDefaultConfig(
    CameraDescription description,
  ) {
    final CameraApi api = _getCameraApi(description);
    switch (api) {
      case CameraApi.android:
        return AndroidCameraController(description);
      case CameraApi.iOS:
        throw UnimplementedError();
      case CameraApi.supportAndroid:
        return SupportAndroidCameraController(description);
    }

    return null; // Unreachable
  }

  static CameraApi _getCameraApi(CameraDescription description) {
    if (description is CameraInfo) {
      return CameraApi.supportAndroid;
    } else if (description is CameraCharacteristics) {
      return CameraApi.android;
    }

    throw ArgumentError.value(
      description.runtimeType,
      'description.runtimeType',
      'Failed to get $CameraApi from',
    );
  }
}

part of super_camera;

enum CameraApi { android, iOS, supportAndroid }
enum LensDirection { front, back, external }

abstract class CameraDescription {
  const CameraDescription._();

  LensDirection get direction;
  dynamic get id;
}

abstract class CameraConfigurator {
  static int _nextHandle;
  final int _handle = _nextHandle++;
  int get previewTextureId;
  Future<void> start();
  Future<void> stop();
  Future<void> dispose();
  Future<void> createPreviewTexture();
}

class CameraController {
  CameraController._({this.description, this.config, this.api})
      : assert(description != null),
        assert(config != null),
        assert(api != null);

  factory CameraController({CameraDescription description}) {
    return CameraController._(
      description: description,
      config: _createDefaultConfig(description),
      api: _getCameraApi(description),
    );
  }

  factory CameraController.customConfigurator({
    CameraDescription description,
    CameraConfigurator config,
  }) {
    return CameraController._(
      description: description,
      config: config,
      api: _getCameraApi(description),
    );
  }

  final CameraDescription description;
  final CameraConfigurator config;
  final CameraApi api;

  Future<void> start() => config.start();

  Future<void> stop() => config.stop();

  Future<void> dispose() => config.dispose();

  static CameraConfigurator _createDefaultConfig(
      CameraDescription description) {
    final CameraApi api = _getCameraApi(description);
    switch (api) {
      case CameraApi.android:
        // TODO: Handle this case.
        return null;
      case CameraApi.iOS:
        // TODO: Handle this case.
        return null;
      case CameraApi.supportAndroid:
        return SupportAndroidCamera.open(description.id);
    }

    return null; // Unreachable
  }

  static CameraApi _getCameraApi(CameraDescription description) {
    if (description is CameraInfo) {
      return CameraApi.supportAndroid;
    }

    throw ArgumentError.value(
      description.runtimeType,
      'description.runtimeType',
      'Failed to get $CameraApi from',
    );
  }
}

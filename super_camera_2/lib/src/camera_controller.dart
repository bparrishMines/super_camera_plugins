part of super_camera;

enum CameraApi { android, iOS, supportAndroid }
enum LensDirection { front, back, external }

abstract class CameraDescription {
  LensDirection get direction;
  dynamic get id;
}

abstract class CameraConfigurator {
  int get previewTextureId;
  Future<void> start();
  Future<void> stop();
  Future<void> dispose();
  Future<void> addPreviewTexture();
}

class CameraController {
  CameraController._({
    @required this.description,
    @required this.configurator,
    @required this.api,
  })  : assert(description != null),
        assert(configurator != null),
        assert(api != null);

  factory CameraController({@required CameraDescription description}) {
    assert(description != null);
    return CameraController._(
      description: description,
      configurator: _createDefaultConfigurator(description),
      api: _getCameraApi(description),
    );
  }

  factory CameraController.customConfigurator({
    @required CameraDescription description,
    @required CameraConfigurator configurator,
  }) {
    assert(description != null);
    assert(configurator != null);

    final CameraApi api = _getCameraApi(description);
    switch (api) {
      case CameraApi.android:
        assert(configurator is AndroidCameraConfigurator);
        break;
      case CameraApi.iOS:
        throw UnimplementedError();
        break;
      case CameraApi.supportAndroid:
        assert(configurator is SupportAndroidCameraConfigurator);
        break;
    }

    return CameraController._(
      description: description,
      configurator: configurator,
      api: api,
    );
  }

  final CameraDescription description;
  final CameraConfigurator configurator;
  final CameraApi api;

  Future<void> start() => configurator.start();
  Future<void> stop() => configurator.stop();
  Future<void> dispose() => configurator.dispose();

  static CameraConfigurator _createDefaultConfigurator(
    CameraDescription description,
  ) {
    final CameraApi api = _getCameraApi(description);
    switch (api) {
      case CameraApi.android:
        return AndroidCameraConfigurator(description);
      case CameraApi.iOS:
        throw UnimplementedError();
      case CameraApi.supportAndroid:
        return SupportAndroidCameraConfigurator(description);
    }

    return null;
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

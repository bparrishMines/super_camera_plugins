part of super_camera;

class Camera {
  Camera._();

  @visibleForTesting
  static const MethodChannel channel = MethodChannel(
    'bmparr2450.plugins/super_camera',
  );

  static Future<List<CameraDevice>> availableCameras() async {
    final List<dynamic> result = await channel.invokeMethod(
      '$Camera#availableCameras',
    );

    return List.unmodifiable(result.map<CameraDevice>((dynamic data) {
      return CameraDevice._fromMap(data);
    }));
  }

  static Future<void> releaseAllResources() async {
    return await channel.invokeMethod('$Camera#releaseAllResources');
  }
}

class CameraExceptionType {
  const CameraExceptionType._(this.value);

  static const CameraExceptionType cameraControllerNotOpen =
      CameraExceptionType._('CameraControllerNotOpen');

  static const CameraExceptionType delegateNameIsNull =
      CameraExceptionType._('DelegateNameIsNull');

  static const CameraExceptionType invalidSetting =
      CameraExceptionType._('InvalidSetting');

  static const CameraExceptionType miscellaneous =
      CameraExceptionType._('Miscellaneous');

  final String value;

  List<CameraExceptionType> get values {
    return <CameraExceptionType>[
      cameraControllerNotOpen,
      delegateNameIsNull,
      invalidSetting,
      miscellaneous,
    ];
  }

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(other) {
    return other is CameraExceptionType && this.value == other.value;
  }

  @override
  String toString() => '$runtimeType($value)';
}

class CameraException implements Exception {
  const CameraException({this.type, this.description});

  final CameraExceptionType type;
  final String description;

  @override
  String toString() => '$runtimeType($type, $description)';
}

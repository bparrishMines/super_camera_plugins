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

  static const CameraExceptionType invalidDelegateName =
      CameraExceptionType._('InvalidDelegateName');

  static const CameraExceptionType invalidSetting =
      CameraExceptionType._('InvalidSetting');

  static const CameraExceptionType unknown = CameraExceptionType._('Unknown');

  final String value;

  static Map<String, CameraExceptionType> _allTypesMap =
      Map.unmodifiable(<String, CameraExceptionType>{
    cameraControllerNotOpen.value: cameraControllerNotOpen,
    invalidDelegateName.value: invalidDelegateName,
    invalidSetting.value: invalidSetting,
    unknown.value: unknown,
  });

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(other) {
    return other is CameraExceptionType && this.value == other.value;
  }

  @override
  String toString() => '$runtimeType.$value';
}

class CameraException implements Exception {
  const CameraException._({this.type, this.code, this.description});

  factory CameraException({String code, String description}) {
    CameraExceptionType type = CameraExceptionType._allTypesMap[code];
    if (type == null) {
      type = CameraExceptionType.unknown;
    }

    return CameraException._(
      type: type,
      code: code,
      description: description,
    );
  }

  final CameraExceptionType type;
  final String code;
  final String description;

  @override
  String toString() => '$runtimeType($type, $description)';
}

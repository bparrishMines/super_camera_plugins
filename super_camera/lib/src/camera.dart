part of super_camera;

class Camera {
  Camera._();

  @visibleForTesting
  static const MethodChannel channel = MethodChannel(
    'bmparr.plugins/super_camera',
  );

  static Future<List<CameraDevice>> availableCameras() {
    throw UnimplementedError();
  }
}

class CameraException implements Exception {
  const CameraException({this.code, this.description});

  final String code;
  final String description;

  @override
  String toString() => '$runtimeType($code, $description)';
}

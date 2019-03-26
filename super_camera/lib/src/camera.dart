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

class CameraException implements Exception {
  const CameraException({this.code, this.description});

  final String code;
  final String description;

  @override
  String toString() => '$runtimeType($code, $description)';
}

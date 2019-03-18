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

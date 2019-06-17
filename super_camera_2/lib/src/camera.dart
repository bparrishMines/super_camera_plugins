part of super_camera;

class Camera {
  Camera._();

  @visibleForTesting
  static const MethodChannel channel = MethodChannel(
    'dev.plugins/super_camera',
  );

  static Future<List<CameraDescription>> availableCameras() async {
    final List<CameraDescription> devices = <CameraDescription>[];

    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
      if (info.version.sdkInt < 21) {
        final int numCameras = await SupportAndroidCamera.getNumberOfCameras();
        for (int i = 0; i < numCameras; i++) {
          devices.add(await SupportAndroidCamera.getCameraInfo(i));
        }
      } else {
        final List<String> cameraIds = await CameraManager.getCameraIdList();
        for (String id in cameraIds) {
          devices.add(await CameraManager.getCameraCharacteristics(id));
        }
      }
    }

    return devices;
  }
}

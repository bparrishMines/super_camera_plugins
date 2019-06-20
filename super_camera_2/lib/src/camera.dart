part of super_camera;

mixin NativeMethodCallHandler {
  final int _handle = Camera.nextHandle++;
}

class Camera {
  Camera._();

  @visibleForTesting
  static const MethodChannel channel = MethodChannel(
    'dev.plugins/super_camera',
  );

  @visibleForTesting
  static int nextHandle = 0;

  static Future<List<CameraDescription>> availableCameras() async {
    final List<CameraDescription> devices = <CameraDescription>[];

    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
      if (info.version.sdkInt < 21 || true) {
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

  static Future<PlatformTexture> createPlatformTexture() async {
    final int handle = nextHandle++;

    final int textureId = await channel.invokeMethod<int>(
      '$Camera#createPlatformTexture',
      <String, dynamic>{'handle': handle},
    );

    return PlatformTexture._(handle: handle, textureId: textureId);
  }
}

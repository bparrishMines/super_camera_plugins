part of super_camera;

class Camera {
  Camera._();

  @visibleForTesting
  static final MethodChannel channel = CameraChannel.channel;

  @visibleForTesting
  static int get nextHandle => CameraChannel.nextHandle;

  @visibleForTesting
  static set nextHandle(int handle) => CameraChannel.nextHandle = handle;

  static Future<List<CameraDescription>> availableCameras() async {
    final List<CameraDescription> devices = <CameraDescription>[];

    final DeviceInfoPlugin infoPlugin = DeviceInfoPlugin();
    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidDeviceInfo info = await infoPlugin.androidInfo;
      if (info.version.sdkInt < 21) {
        final int numCameras = await SupportAndroidCamera.getNumberOfCameras();
        for (int i = 0; i < numCameras; i++) {
          devices.add(await SupportAndroidCamera.getCameraInfo(i));
        }
      } else {
        final List<String> cameraIds =
            await CameraManager.instance.getCameraIdList();
        for (String id in cameraIds) {
          devices.add(
            await CameraManager.instance.getCameraCharacteristics(id),
          );
        }
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final IosDeviceInfo info = await infoPlugin.iosInfo;
      final double version = double.tryParse(info.systemVersion) ?? 8.0;
      if (version >= 10) {
        final CaptureDiscoverySession session = CaptureDiscoverySession(
          deviceTypes: <CaptureDeviceType>[
            CaptureDeviceType.builtInWideAngleCamera
          ],
          position: CaptureDevicePosition.unspecified,
          mediaType: MediaType.video,
        );

        devices.addAll(await session.devices);
      } else {
        devices.addAll(await CaptureDevice.getDevices(MediaType.video));
      }
    } else {
      throw UnimplementedError('$defaultTargetPlatform not supported');
    }

    return devices;
  }

  static Future<PlatformTexture> createPlatformTexture() async {
    final int handle = nextHandle++;

    final int textureId = await channel.invokeMethod<int>(
      '$Camera#createPlatformTexture',
      <String, dynamic>{'textureHandle': handle},
    );

    return PlatformTexture._(handle: handle, textureId: textureId);
  }
}

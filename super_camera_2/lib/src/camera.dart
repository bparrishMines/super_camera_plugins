part of super_camera;

typedef _CameraCallback = void Function(dynamic result);

class Camera {
  Camera._();

  static final Map<int, dynamic> _callbacks = <int, _CameraCallback>{};

  @visibleForTesting
  static final MethodChannel channel = MethodChannel(
    'dev.plugins/super_camera',
  )..setMethodCallHandler(
      (MethodCall call) async {
        assert(call.method == 'handleCallback');

        final int handle = call.arguments['handle'];
        if (_callbacks[handle] != null) _callbacks[handle](call.arguments);
      },
    );

  @visibleForTesting
  static int nextHandle = 0;

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

  static void _registerCallback(int handle, _CameraCallback callback) {
    assert(handle != null);
    assert(_CameraCallback != null);

    assert(!_callbacks.containsKey(handle));
    _callbacks[handle] = callback;
  }

  static void _unregisterCallback(int handle) {
    assert(handle != null);
    _callbacks.remove(handle);
  }
}

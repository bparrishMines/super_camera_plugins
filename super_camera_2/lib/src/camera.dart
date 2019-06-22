part of super_camera;

mixin NativeMethodCallHandler {
  final int _handle = Camera.nextHandle++;
}

typedef _CameraCallback = void Function(dynamic result);

class Camera {
  Camera._();

  static bool _methodHandlerSet = false;
  static final Map<int, dynamic> _callbacks = <int, _CameraCallback>{};

  @visibleForTesting
  static final MethodChannel channel = MethodChannel(
    'dev.plugins/super_camera',
  );

  @visibleForTesting
  static int nextHandle = 0;

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
        final List<String> cameraIds =
            await CameraManager.instance.getCameraIdList();
        for (String id in cameraIds) {
          devices.add(
            await CameraManager.instance.getCameraCharacteristics(id),
          );
        }
      }
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
    if (!_methodHandlerSet) {
      channel.setMethodCallHandler(
        (MethodCall call) async {
          assert(call.method == 'handleCallback');

          final int handle = call.arguments['handle'];
          if (_callbacks[handle] != null) _callbacks[handle](call.arguments);
        },
      );
      _methodHandlerSet = true;
    }

    assert(!_callbacks.containsKey(handle));
    _callbacks[handle] = callback;
  }

  static void _unregisterCallback(int handle) => _callbacks.remove(handle);
}

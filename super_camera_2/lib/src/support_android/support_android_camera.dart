part of super_camera;

class SupportAndroidCamera with _NativeMethodCallHandler, _CameraClosable {
  SupportAndroidCamera._();

  static Future<int> getNumberOfCameras() {
    return Camera.channel.invokeMethod<int>(
      '$SupportAndroidCamera#getNumberOfCameras',
    );
  }

  static SupportAndroidCamera open(int cameraId) {
    final SupportAndroidCamera camera = SupportAndroidCamera._();

    Camera.channel.invokeMethod<int>(
      '$SupportAndroidCamera#open',
      <String, dynamic>{'cameraId': cameraId, 'cameraHandle': camera._handle},
    );

    return camera;
  }

  static Future<CameraInfo> getCameraInfo(int cameraId) async {
    final Map<String, dynamic> infoMap =
        await Camera.channel.invokeMapMethod<String, dynamic>(
      '$SupportAndroidCamera#getCameraInfo',
      <String, dynamic>{'cameraId': cameraId},
    );

    return CameraInfo._fromMap(infoMap);
  }

  set previewTexture(PlatformTexture texture) {
    assert(!_isClosed);

    Camera.channel.invokeMethod<void>(
      '$SupportAndroidCamera#previewTexture',
      <String, dynamic>{'handle': _handle, 'textureHandle': texture?._handle},
    );
  }

  Future<void> startPreview() {
    assert(!_isClosed);

    return Camera.channel.invokeMethod<void>(
      '$SupportAndroidCamera#startPreview',
      <String, dynamic>{'handle': _handle},
    );
  }

  Future<void> stopPreview() {
    if (_isClosed) return Future<void>.value();

    return Camera.channel.invokeMethod<void>(
      '$SupportAndroidCamera#stopPreview',
      <String, dynamic>{'handle': _handle},
    );
  }

  Future<void> release() {
    if (_isClosed) return Future<void>.value();

    _isClosed = true;
    return Camera.channel.invokeMethod<void>(
      '$SupportAndroidCamera#release',
      <String, dynamic>{'handle': _handle},
    );
  }
}

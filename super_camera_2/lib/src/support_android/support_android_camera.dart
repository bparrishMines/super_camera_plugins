part of super_camera;

class SupportAndroidCamera extends CameraConfigurator {
  SupportAndroidCamera._();

  int _previewTextureId;

  static Future<int> getNumberOfCameras() {
    return Camera.channel.invokeMethod<int>(
      '$SupportAndroidCamera#getNumberOfCameras',
    );
  }

  static SupportAndroidCamera open(int cameraId) {
    final SupportAndroidCamera camera = SupportAndroidCamera._();

    Camera.channel.invokeMethod<int>(
      '$SupportAndroidCamera#open',
      <String, dynamic>{'cameraId': cameraId, 'handle': camera._handle},
    );

    return camera;
  }

  static Future<CameraInfo> getCameraInfo(int cameraId) async {
    final Map<String, dynamic> infoMap =
        await Camera.channel.invokeMapMethod<String, dynamic>(
      '$SupportAndroidCamera#getCameraInfo',
    );

    return CameraInfo._fromMap(infoMap);
  }

  Future<void> startPreview() {
    return Camera.channel.invokeMethod<void>(
      '$SupportAndroidCamera#startPreview',
      <String, dynamic>{'handle': _handle},
    );
  }

  Future<void> stopPreview() {
    return Camera.channel.invokeMethod<void>(
      '$SupportAndroidCamera#stopPreview',
      <String, dynamic>{'handle': _handle},
    );
  }

  Future<void> release() {
    return Camera.channel.invokeMethod<void>(
      '$SupportAndroidCamera#release',
      <String, dynamic>{'handle': _handle},
    );
  }

  @override
  int get previewTextureId => _previewTextureId;

  @override
  Future<void> dispose() => release();

  @override
  Future<void> start() => startPreview();

  @override
  Future<void> stop() => stopPreview();

  @override
  Future<void> createPreviewTexture() {
    if (previewTextureId != null) return Future.value();

    return Camera.channel
        .invokeMethod<int>('$SupportAndroidCamera#createPreviewTexture')
        .then((int textureId) => _previewTextureId = textureId);
  }
}

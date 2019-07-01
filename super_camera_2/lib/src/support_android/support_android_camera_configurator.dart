part of support_android_camera;

class SupportAndroidCameraConfigurator
    with CameraClosable
    implements CameraConfigurator {
  SupportAndroidCameraConfigurator(this.info) : assert(info != null) {
    _camera = SupportAndroidCamera.open(info.id);
  }

  PlatformTexture _texture;
  SupportAndroidCamera _camera;

  final CameraInfo info;

  SupportAndroidCamera get camera => _camera;

  @override
  Future<void> addPreviewTexture() async {
    assert(!isClosed);
    if (_texture == null) _texture = await Camera.createPlatformTexture();
    _camera.previewTexture = _texture;
  }

  @override
  Future<void> dispose() async {
    isClosed = true;
    await _camera.release();
    await _texture?.release();
  }

  @override
  int get previewTextureId => _texture?.textureId;

  @override
  Future<void> start() {
    assert(!isClosed);
    return _camera.startPreview();
  }

  @override
  Future<void> stop() {
    if (isClosed) return Future<void>.value();
    return _camera.stopPreview();
  }
}

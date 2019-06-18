part of super_camera;

class SupportAndroidCameraController implements CameraController {
  SupportAndroidCameraController(this.info) : assert(info != null) {
    _camera = SupportAndroidCamera.open(info.id);
  }

  PlatformTexture _texture;
  SupportAndroidCamera _camera;

  final CameraInfo info;

  SupportAndroidCamera get camera => _camera;

  @override
  Future<void> addPreviewTexture() async {
    _texture = await Camera.createPlatformTexture();
    _camera.previewTexture = _texture;
  }

  @override
  Future<void> dispose() {
    return _camera.release().then((_) => _texture?.release());
  }

  @override
  int get previewTextureId => _texture?.textureId;

  @override
  Future<void> start() {
    return _camera.startPreview();
  }

  @override
  Future<void> stop() {
    return _camera.stopPreview();
  }

  @override
  CameraApi get api => CameraApi.supportAndroid;

  @override
  CameraController get controller => this;

  @override
  CameraDescription get description => info;
}

part of super_camera;

class AndroidCameraConfigurator implements CameraConfigurator {
  AndroidCameraConfigurator(this.characteristics)
      : assert(characteristics != null) {
    CameraManager.instance.openCamera(
      characteristics.id,
      (CameraDeviceState state, CameraDevice device) {
        _device = device;
      },
    );
  }

  PlatformTexture _texture;
  CameraDevice _device;
  CameraCaptureSession _session;
  final List<Surface> _outputs = <Surface>[];
  CaptureRequest _previewCaptureRequest;

  final CameraCharacteristics characteristics;

  @override
  Future<void> addPreviewTexture() async {
    while (_device == null) {}

    if (_outputs.any((Surface surface) => surface is PreviewTexture)) return;

    if (_texture == null) _texture = await Camera.createPlatformTexture();

    final CaptureRequest request =
        await _device.createCaptureRequest(Template.preview);

    final PreviewTexture previewTexture = PreviewTexture(
      platformTexture: _texture,
      surfaceTexture: SurfaceTexture(),
    );

    _outputs.add(previewTexture);

    _previewCaptureRequest = request.copyWith(
      targets: _outputs,
    );
  }

  @override
  Future<void> dispose() {
    return Future.wait(
      <Future<void>>[_session?.close(), _device?.close(), _texture?.release()],
    );
  }

  @override
  int get previewTextureId => _texture?.textureId;

  @override
  Future<void> start() async {
    while (_device == null) {}

    _device.createCaptureSession(
      _outputs,
      (CameraCaptureSessionState state, CameraCaptureSession session) {
        _session = session;
        if (state == CameraCaptureSessionState.configured) {
          session.setRepeatingRequest(request: _previewCaptureRequest);
        }
      },
    );
  }

  @override
  Future<void> stop() {
    if (_session == null) return Future<void>.value();
    return _session.close().then((_) => _session = null);
  }
}

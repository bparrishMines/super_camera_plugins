part of android_camera;

class AndroidCameraConfigurator
    with CameraClosable
    implements CameraConfigurator {
  AndroidCameraConfigurator(this.characteristics)
      : assert(characteristics != null) {
    CameraManager.instance.openCamera(
      characteristics.id,
      (CameraDeviceState state, CameraDevice device) async {
        _device = device;
        _deviceCallbackCompleter.complete();
      },
    );
  }

  final Completer<void> _deviceCallbackCompleter = Completer<void>();

  PlatformTexture _texture;
  CameraDevice _device;
  CameraCaptureSession _session;
  final List<Surface> _outputs = <Surface>[];
  CaptureRequest _previewCaptureRequest;

  final CameraCharacteristics characteristics;

  @override
  Future<void> addPreviewTexture() async {
    assert(!isClosed);

    await _deviceCallbackCompleter.future;

    if (_texture != null) return Future<void>.value();

    _texture = await Camera.createPlatformTexture();
    final CaptureRequest request = _device.createCaptureRequest(
      Template.preview,
    );

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
  Future<void> dispose() async {
    if (isClosed) return Future<void>.value();

    await _deviceCallbackCompleter.future;

    isClosed = true;

    await stop();
    await _device.close();
    await _texture?.release();
  }

  @override
  int get previewTextureId => _texture?.textureId;

  @override
  Future<void> start() async {
    assert(!isClosed);

    await _deviceCallbackCompleter.future;

    final Completer<void> completer = Completer<void>();

    _device.createCaptureSession(
      _outputs,
      (CameraCaptureSessionState state, CameraCaptureSession session) {
        _session = session;
        if (state == CameraCaptureSessionState.configured) {
          session.setRepeatingRequest(request: _previewCaptureRequest);
        }
        completer.complete();
      },
    );

    return completer.future;
  }

  @override
  Future<void> stop() async {
    await _deviceCallbackCompleter.future;

    if (isClosed || _session == null) return Future<void>.value();

    final CameraCaptureSession tmpSess = _session;
    _session = null;

    return tmpSess.close();
  }
}

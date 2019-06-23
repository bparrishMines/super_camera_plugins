part of super_camera;

typedef _AsyncVoidCallback = Future<void> Function();

class AndroidCameraConfigurator implements CameraConfigurator {
  AndroidCameraConfigurator(this.characteristics)
      : assert(characteristics != null) {
    CameraManager.instance.openCamera(
      characteristics.id,
      (CameraDeviceState state, CameraDevice device) async {
        _device = device;

        for (_AsyncVoidCallback waitingMethod in _waitingMethods) {
          await waitingMethod();
        }
        _deviceCallbackCompleter.complete();
      },
    );
  }

  final Completer<void> _deviceCallbackCompleter = Completer<void>();
  final List<_AsyncVoidCallback> _waitingMethods = <_AsyncVoidCallback>[];

  PlatformTexture _texture;
  CameraDevice _device;
  CameraCaptureSession _session;
  final List<Surface> _outputs = <Surface>[];
  CaptureRequest _previewCaptureRequest;

  final CameraCharacteristics characteristics;

  @override
  Future<void> addPreviewTexture() async {
    if (_device == null) {
      _waitingMethods.add(() => addPreviewTexture());
      return _deviceCallbackCompleter.future;
    }

    if (_texture != null) return Future<void>.value();

    _texture = await Camera.createPlatformTexture();
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
    if (_device == null) {
      _waitingMethods.add(() => dispose());
      return _deviceCallbackCompleter.future;
    }

    return stop().then((_) => _device.close()).then((_) => _texture?.release());
  }

  @override
  int get previewTextureId => _texture?.textureId;

  @override
  Future<void> start() async {
    if (_device == null) {
      _waitingMethods.add(() => start());
      return _deviceCallbackCompleter.future;
    }

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
  Future<void> stop() {
    if (_device == null) {
      _waitingMethods.add(() => stop());
      return _deviceCallbackCompleter.future;
    }

    if (_session == null) return Future<void>.value();
    return _session?.close()?.then((_) => _session = null);
  }
}

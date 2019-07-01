part of super_camera;

class IOSCameraConfigurator implements CameraConfigurator {
  IOSCameraConfigurator(this.device)
      : _session = CaptureSession(),
        assert(device != null) {
    final CaptureDeviceInput input = CaptureDeviceInput(device: device);
    _session.addInput(input);
  }

  final CaptureSession _session;
  PlatformTexture _texture;

  final CaptureDevice device;

  @override
  Future<void> addPreviewTexture() async {
    if (_texture == null) _texture = await Camera.createPlatformTexture();

    final CaptureVideoDataOutput output = CaptureVideoDataOutput(
      delegate: CaptureVideoDataOutputSampleBufferDelegate(
        texture: _texture,
      ),
      formatType: PixelFormatType.bgra32,
    );

    _session.addOutput(output);
  }

  @override
  Future<void> dispose() async {
    await stop();
    return _texture?.release();
  }

  @override
  int get previewTextureId => _texture?.textureId;

  @override
  Future<void> start() {
    return _session.startRunning();
  }

  @override
  Future<void> stop() {
    return _session.stopRunning();
  }
}

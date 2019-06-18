part of super_camera;

class AndroidCameraController implements CameraController {
  AndroidCameraController(this.characteristics)
      : assert(characteristics != null) {
    CameraManager.openCamera(cameraId, callback)
  }

  CameraDevice _device;
  CameraCaptureSession _session;

  final CameraCharacteristics characteristics;

  @override
  Future<void> addPreviewTexture() {
    // TODO: implement createPreviewTexture
    return null;
  }

  @override
  Future<void> dispose() {
    // TODO: implement dispose
    return null;
  }

  @override
  // TODO: implement previewTextureId
  int get previewTextureId => null;

  @override
  Future<void> start() {
    // TODO: implement start
    return null;
  }

  @override
  Future<void> stop() {
    // TODO: implement stop
    return null;
  }

  @override
  // TODO: implement api
  CameraApi get api => null;

  @override
  // TODO: implement controller
  CameraController get controller => null;

  @override
  // TODO: implement description
  CameraDescription get description => null;
}

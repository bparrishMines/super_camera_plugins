part of super_camera;

class CameraController {
  CameraController(this.device);

  final CameraDevice device;

  void open({
    Function() onSuccess,
    Function(CameraException exception) onFailure,
  }) async {}
  Future<void> close() async {}

  void putSingleCaptureRequest(SingleCaptureSettings settings) async {}
  void putRepeatingCaptureRequest(RepeatingCaptureSettings settings) async {}

  Future<void> stopRepeatingCaptureRequests() async {}

  Future<bool> hasRepeatingCaptureRequests() async {
    return null;
  }
}

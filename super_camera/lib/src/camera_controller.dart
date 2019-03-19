part of super_camera;

class CameraController {
  CameraController(this.device);

  final CameraDevice device;

  void open({
    Function() onSuccess,
    Function(CameraException exception) onFailure,
  }) async {
    try {
      await Camera.channel.invokeMethod(
        'CameraController#open',
        <String, dynamic>{
          'cameraId': device.cameraId,
        },
      );

      if (onSuccess != null) {
        onSuccess();
      }
    } on PlatformException catch (exception) {
      if (onFailure != null) {
        onFailure(CameraException(
          code: exception.code,
          description: exception.message,
        ));
      }
    }
  }

  Future<void> close() async {
    return Camera.channel.invokeMethod(
      'CameraController#close',
      <String, dynamic>{
        'cameraId': device.cameraId,
      },
    );
  }

  void putSingleCaptureRequest(SingleCaptureSettings settings) async {}
  void putRepeatingCaptureRequest(RepeatingCaptureSettings settings) async {}

  Future<void> stopRepeatingCaptureRequests() async {}

  Future<bool> hasRepeatingCaptureRequests() async {
    return null;
  }
}

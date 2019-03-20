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
        <String, dynamic>{'cameraId': device.cameraId},
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
      <String, dynamic>{'cameraId': device.cameraId},
    );
  }

  void putSingleCaptureRequest(SingleCaptureSettings settings) async {}

  void putRepeatingCaptureRequest(RepeatingCaptureSettings settings) async {
    try {
      final dynamic result = await Camera.channel.invokeMethod(
        'CameraController#putRepeatingCaptureRequest',
        <String, dynamic>{
          'cameraId': device.cameraId,
          'settings': settings._serialize(),
        },
      );

      if (settings.onSuccess != null) {
        settings.onSuccess(result);
      }
    } on PlatformException catch (exception) {
      if (settings.onFailure != null) {
        settings.onFailure(CameraException(
          code: exception.code,
          description: exception.message,
        ));
      }
    }
  }

  Future<void> stopRepeatingCaptureRequests() async {
    return await Camera.channel.invokeMethod(
      'CameraController#stopRepeatingCaptureRequest',
      <String, dynamic>{'cameraId': device.cameraId},
    );
  }
}

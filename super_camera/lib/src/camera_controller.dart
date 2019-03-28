part of super_camera;

class CameraController {
  CameraController._(this.device, this.channel);

  factory CameraController(CameraDevice device) {
    assert(device != null);

    final String channelName = '${Camera.channel.name}/${_nextHandle++}';
    final MethodChannel channel = MethodChannel(channelName);

    Camera.channel.invokeMethod(
      '$Camera#createCameraController',
      <String, dynamic>{
        'channelName': channelName,
        'cameraId': device.cameraId,
      },
    );

    return CameraController._(device, channel);
  }

  static int _nextHandle = 0;

  @visibleForTesting
  final MethodChannel channel;
  final CameraDevice device;

  void open({
    Function() onSuccess,
    Function(CameraException exception) onFailure,
  }) async {
    try {
      await channel.invokeMethod('$CameraController#open');

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

  Future<void> startRunning() {
    return channel.invokeMethod('$CameraController#startRunning');
  }

  void takePhoto(PhotoSettings settings) async {
    assert(settings != null);

    try {
      final dynamic result = await channel.invokeMethod(
        '$CameraController#takePhoto',
        settings._serialize(),
      );

      if (settings.delegateSettings.onSuccess != null) {
        settings.delegateSettings.onSuccess(result);
      }
    } on PlatformException catch (exception) {
      if (settings.delegateSettings.onFailure != null) {
        settings.delegateSettings.onFailure(CameraException(
          code: exception.code,
          description: exception.message,
        ));
      }
    }
  }

  void setVideoSettings(VideoSettings settings) async {
    assert(settings != null);

    try {
      final dynamic result = await channel.invokeMethod(
        '$CameraController#setVideoSettings',
        settings._serialize(),
      );

      if (settings.delegateSettings.onSuccess != null) {
        settings.delegateSettings.onSuccess(result);
      }
    } on PlatformException catch (exception) {
      if (settings.delegateSettings.onFailure != null) {
        settings.delegateSettings.onFailure(CameraException(
          code: exception.code,
          description: exception.message,
        ));
      }
    }
  }

  Future<void> stopRunning() {
    return channel.invokeMethod('$CameraController#stopRunning');
  }

  Future<void> close() {
    return channel.invokeMethod('$CameraController#close');
  }
}

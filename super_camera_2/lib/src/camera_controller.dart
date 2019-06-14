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

  Future<void> open() {
    return _invokeMethod(method: '$CameraController#open');
  }

  Future<void> startRunning() {
    return _invokeMethod(method: '$CameraController#startRunning');
  }

  Future<void> setVideoSettings(VideoSettings settings) {
    assert(settings != null);

    return _invokeMethod(
      method: '$CameraController#setVideoSettings',
      arguments: settings._serialize(),
      onSuccess: settings.delegate.onConfigured,
    );
  }

  Future<void> setPhotoSettings(PhotoSettings settings) {
    assert(settings != null);

    return _invokeMethod(
      method: '$CameraController#setPhotoSettings',
      arguments: settings._serialize(),
      onSuccess: settings.delegate.onConfigured,
    );
  }

  Future<void> takePhoto() {
    return _invokeMethod(method: '$CameraController#takePhoto');
  }

  Future<void> stopRunning() {
    return _invokeMethod(method: '$CameraController#stopRunning');
  }

  Future<void> close() {
    return _invokeMethod(method: '$CameraController#close');
  }

  // Invokes method normally, but also catches all PlatformExceptions.
  Future<void> _invokeMethod({
    @required String method,
    Map<String, dynamic> arguments,
    Function(dynamic result) onSuccess,
  }) async {
    try {
      final dynamic result = await channel.invokeMethod(method, arguments);

      if (onSuccess != null) {
        onSuccess(result);
      }
    } on PlatformException catch (exception) {
      throw CameraException(
        code: exception.code,
        description: exception.message,
      );
    }
  }
}

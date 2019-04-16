part of super_camera;

class CameraController {
  CameraController._(this.device, this.channel);

  factory CameraController(CameraDevice device, {bool useCamera1 = false}) {
    assert(device != null);
    assert(useCamera1 != null);

    final String channelName = '${Camera.channel.name}/${_nextHandle++}';
    final MethodChannel channel = MethodChannel(channelName);

    Camera.channel.invokeMethod(
      '$Camera#createCameraController',
      <String, dynamic>{
        'channelName': channelName,
        'cameraId': device.cameraId,
        'useCamera1': useCamera1,
      },
    );

    return CameraController._(device, channel);
  }

  static int _nextHandle = 0;

  @visibleForTesting
  final MethodChannel channel;
  final CameraDevice device;

  void open({
    VoidCallback onSuccess,
    CameraFailureCallback onFailure,
  }) {
    _invokeMethod(
      method: '$CameraController#open',
      settings: null,
      onSuccess: onSuccess,
      onSuccessHasResult: false,
      onFailure: onFailure,
    );
  }

  void startRunning({
    VoidCallback onSuccess,
    CameraFailureCallback onFailure,
  }) {
    _invokeMethod(
      method: '$CameraController#startRunning',
      settings: null,
      onSuccess: onSuccess,
      onSuccessHasResult: false,
      onFailure: onFailure,
    );
  }

  void takePhoto([Function(CameraException exception) onFailure]) {
    _invokeMethod(
      method: '$CameraController#takePhoto',
      settings: null,
      onSuccess: null,
      onSuccessHasResult: false,
      onFailure: onFailure,
    );
  }

  void setVideoSettings(VideoSettings settings) {
    assert(settings != null);

    _invokeMethod(
      method: '$CameraController#setVideoSettings',
      settings: settings._serialize(),
      onSuccess: settings.delegateSettings.onSuccess,
      onSuccessHasResult: true,
      onFailure: settings.delegateSettings.onFailure,
    );
  }

  void setPhotoSettings(PhotoSettings settings) {
    assert(settings != null);

    _invokeMethod(
      method: '$CameraController#setPhotoSettings',
      settings: settings._serialize(),
      onSuccess: settings.delegateSettings.onSuccess,
      onSuccessHasResult: true,
      onFailure: settings.delegateSettings.onFailure,
    );
  }

  Future<void> stopRunning() {
    return channel.invokeMethod('$CameraController#stopRunning');
  }

  Future<void> close() {
    return channel.invokeMethod('$CameraController#close');
  }

  void _invokeMethod({
    @required String method,
    @required Map<String, dynamic> settings,
    @required Function onSuccess,
    @required bool onSuccessHasResult,
    @required CameraFailureCallback onFailure,
  }) async {
    try {
      final dynamic result = await channel.invokeMethod(method, settings);

      if (onSuccess != null) {
        if (onSuccessHasResult) {
          onSuccess(result);
        } else {
          onSuccess();
        }
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
}

part of super_camera;

class CameraManager with NativeMethodCallHandler {
  CameraManager._() {
    Camera.channel.invokeMethod<void>(
      '$CameraManager()',
      <String, dynamic>{'managerHandle': _handle},
    );
  }

  static final CameraManager instance = CameraManager._();

  Future<CameraCharacteristics> getCameraCharacteristics(
    String cameraId,
  ) async {
    assert(cameraId != null);

    final Map<String, dynamic> data =
        await Camera.channel.invokeMapMethod<String, dynamic>(
      '$CameraManager#getCameraCharacteristics',
      <String, dynamic>{'cameraId': cameraId, 'handle': _handle},
    );

    return CameraCharacteristics._fromMap(data);
  }

  Future<List<String>> getCameraIdList() {
    return Camera.channel.invokeListMethod<String>(
      '$CameraManager#getCameraIdList',
      <String, dynamic>{'handle': _handle},
    );
  }

  void openCamera(String cameraId, CameraDeviceStateCallback stateCallback) {
    assert(cameraId != null);
    assert(stateCallback != null);

    final int deviceHandle = Camera.nextHandle++;

    final String callbackChannelName =
        '${Camera.channel}/$CameraDeviceStateCallback/$deviceHandle';

    Camera.channel.invokeMethod<void>(
      '$CameraManager#openCamera',
      <String, dynamic>{
        'handle': _handle,
        'cameraId': cameraId,
        'cameraHandle': deviceHandle,
        'stateCallbackChannelName': callbackChannelName,
      },
    ).then((_) {
      final EventChannel callbackChannel = EventChannel(callbackChannelName);
      final CameraDevice device = CameraDevice._(
        id: cameraId,
        handle: deviceHandle,
      );

      device._subscription = _setUpStateCallbackSubscription(
        callbackChannel: callbackChannel,
        stateCallback: stateCallback,
        device: device,
      );
    });
  }

  static StreamSubscription<dynamic> _setUpStateCallbackSubscription({
    @required EventChannel callbackChannel,
    @required CameraDeviceStateCallback stateCallback,
    @required CameraDevice device,
  }) {
    return callbackChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        final String deviceState = event['$CameraDeviceState'];

        final CameraDeviceState state = CameraDeviceState.values.firstWhere(
          (CameraDeviceState state) => state.toString() == deviceState,
        );

        stateCallback(state, device);
      },
    );
  }
}

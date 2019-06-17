part of super_camera;

enum Template { preview }

class CameraDevice {
  CameraDevice._(this.id) : assert(id != null);

  final int _handle = Camera._nextHandle++;
  StreamSubscription<dynamic> _subscription;

  final String id;

  Future<CaptureRequest> createCaptureRequest(Template template) async {
    final Map<String, dynamic> data =
        await Camera.channel.invokeMapMethod<dynamic, dynamic>(
      '$CameraDevice#createCaptureRequest',
      <String, dynamic>{'$Template': template.toString(), 'handle': _handle},
    );

    return CaptureRequest._fromMap(
      template: template,
      map: data,
    );
  }

  Future<void> close() {
    _subscription?.cancel();
    return Camera.channel.invokeMethod<void>(
      '$CameraDevice#close',
      <String, dynamic>{'handle': _handle},
    );
  }

  void _setUpStateCallbackSubscription({
    String stateCallbackChannelName,
    CameraDeviceStateCallback stateCallback,
  }) {
    _subscription =
        EventChannel(stateCallbackChannelName).receiveBroadcastStream().listen(
      (dynamic event) {
        final String deviceState = event['$CameraDeviceState'];

        CameraDeviceState state;
        if (deviceState == CameraDeviceState.closed.toString()) {
          state = CameraDeviceState.closed;
        } else if (deviceState == CameraDeviceState.disconnected.toString()) {
          state = CameraDeviceState.disconnected;
        } else if (deviceState == CameraDeviceState.error.toString()) {
          state = CameraDeviceState.error;
        } else if (deviceState == CameraDeviceState.opened.toString()) {
          state = CameraDeviceState.opened;
        }

        if (state == null) {
          throw StateError('Failed parsing of $CameraDeviceState');
        }
        stateCallback(state, this);
      },
    );
  }
}

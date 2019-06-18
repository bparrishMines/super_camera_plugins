part of super_camera;

typedef CameraCaptureSessionStateCallback = Function(
  CameraCaptureSessionState state,
  CameraCaptureSession session,
);

enum CameraCaptureSessionState { configured }

class CameraCaptureSession {
  CameraCaptureSession._();

  final int _handle = Camera.nextHandle++;
  StreamSubscription<dynamic> _subscription;
  int _previewTextureId;

  int get previewTextureId => _previewTextureId;

  Future<void> close() {
    _subscription.cancel();
    return Camera.channel.invokeMethod<void>(
      '$CameraDevice#close',
      <String, dynamic>{'handle': _handle},
    );
  }

  void _setUpStateCallbackSubscription({
    String stateCallbackChannelName,
    CameraCaptureSessionStateCallback stateCallback,
  }) {
    _subscription =
        EventChannel(stateCallbackChannelName).receiveBroadcastStream().listen(
      (dynamic event) {
        final String deviceState = event['$CameraCaptureSessionState'];

        CameraCaptureSessionState state;
        if (deviceState == CameraCaptureSessionState.configured.toString()) {
          state = CameraCaptureSessionState.configured;
        }

        if (state == null) {
          throw StateError('Failed parsing of $CameraCaptureSessionState');
        }
        stateCallback(state, this);
      },
    );
  }
}

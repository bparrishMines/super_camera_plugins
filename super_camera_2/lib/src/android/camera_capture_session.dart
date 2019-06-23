part of super_camera;

typedef CameraCaptureSessionStateCallback = Function(
  CameraCaptureSessionState state,
  CameraCaptureSession session,
);

enum CameraCaptureSessionState { configured, configureFailed, closed }

class CameraCaptureSession with _NativeMethodCallHandler {
  CameraCaptureSession._(
    this._cameraDeviceHandle,
    CameraCaptureSessionStateCallback stateCallback,
  )   : assert(_cameraDeviceHandle != null),
        assert(stateCallback != null) {
    Camera._registerCallback(
      _handle,
      (dynamic event) {
        final String deviceState = event['$CameraCaptureSessionState'];

        final CameraCaptureSessionState state =
            CameraCaptureSessionState.values.firstWhere(
          (CameraCaptureSessionState state) => state.toString() == deviceState,
        );

        if (state == CameraCaptureSessionState.configureFailed ||
            state == CameraCaptureSessionState.closed) {
          close();
        }
        stateCallback(state, this);
      },
    );
  }

  final int _cameraDeviceHandle;

  Future<void> setRepeatingRequest({@required CaptureRequest request}) {
    assert(!_isClosed);
    assert(request != null);

    return Camera.channel.invokeMethod<void>(
      '$CameraCaptureSession#setRepeatingRequest',
      <String, dynamic>{
        'handle': _handle,
        'cameraDeviceHandle': _cameraDeviceHandle,
        '$CaptureRequest': request.asMap(),
      },
    );
  }

  Future<void> close() {
    if (_isClosed) return Future<void>.value();

    return Camera.channel.invokeMethod<void>(
      '$CameraCaptureSession#close',
      <String, dynamic>{'handle': _handle},
    ).then((_) {
      Camera._unregisterCallback(_handle);
      _isClosed = true;
    });
  }
}

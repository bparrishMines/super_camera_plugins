part of super_camera;

typedef CameraCaptureSessionStateCallback = Function(
  CameraCaptureSessionState state,
  CameraCaptureSession session,
);

enum CameraCaptureSessionState { configured, configureFailed, closed }

class CameraCaptureSession with _NativeMethodCallHandler, _CameraClosable {
  CameraCaptureSession._(
    this._cameraDeviceHandle,
    List<Surface> outputs,
    CameraCaptureSessionStateCallback stateCallback,
  )   : outputs = List<Surface>.unmodifiable(outputs),
        assert(_cameraDeviceHandle != null),
        assert(outputs != null),
        assert(outputs.isNotEmpty),
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

  final List<Surface> outputs;

  Future<void> setRepeatingRequest({@required CaptureRequest request}) {
    assert(!_isClosed);
    assert(request != null);
    assert(request.targets.isNotEmpty);
    assert(request.targets.every(
      (Surface surface) => outputs.contains(surface),
    ));

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

    _isClosed = true;
    return Camera.channel.invokeMethod<void>(
      '$CameraCaptureSession#close',
      <String, dynamic>{'handle': _handle},
    ).then((_) => Camera._unregisterCallback(_handle));
  }
}

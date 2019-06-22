part of super_camera;

enum CameraDeviceState { closed, disconnected, error, opened }
enum Template { preview }

typedef CameraDeviceStateCallback = void Function(
  CameraDeviceState state,
  CameraDevice device,
);

class CameraDevice with NativeMethodCallHandler {
  CameraDevice._(this.id, CameraDeviceStateCallback stateCallback)
      : assert(id != null),
        assert(stateCallback != null) {
    Camera._registerCallback(
      _handle,
      (dynamic event) {
        final String deviceState = event['$CameraDeviceState'];

        final CameraDeviceState state = CameraDeviceState.values.firstWhere(
          (CameraDeviceState state) => state.toString() == deviceState,
        );

        if (state == CameraDeviceState.closed) close();
        stateCallback(state, this);
      },
    );
  }

  final String id;

  Future<CaptureRequest> createCaptureRequest(Template template) async {
    assert(template != null);
    /*
    final Map<String, dynamic> data =
        await Camera.channel.invokeMapMethod<dynamic, dynamic>(
      '$CameraDevice#createCaptureRequest',
      <String, dynamic>{'$Template': template.toString(), 'handle': _handle},
    );
    */

    /*
    return CaptureRequest._fromMap(
      template: template,
      map: data,
    );
    */
    return Future<CaptureRequest>.value(CaptureRequest._(
      template: template,
      targets: <Surface>[],
    ));
  }

  void createCaptureSession(
    List<Surface> outputs,
    CameraCaptureSessionStateCallback callback,
  ) {
    assert(outputs != null);
    assert(outputs.isNotEmpty);
    assert(callback != null);

    final CameraCaptureSession session = CameraCaptureSession._(
      _handle,
      callback,
    );

    final List<Map<String, dynamic>> outputData = outputs
        .map<Map<String, dynamic>>(
          (Surface surface) => surface.asMap(),
        )
        .toList();

    Camera.channel.invokeMethod<void>(
      '$CameraDevice#createCaptureSession',
      <String, dynamic>{
        'handle': _handle,
        'sessionHandle': session._handle,
        'outputs': outputData,
      },
    );
  }

  Future<void> close() {
    return Camera.channel.invokeMethod<void>(
      '$CameraDevice#close',
      <String, dynamic>{'handle': _handle},
    ).then((_) => Camera._unregisterCallback(_handle));
  }
}

part of super_camera;

enum CameraDeviceState { closed, disconnected, error, opened }
enum Template { preview }

typedef CameraDeviceStateCallback = Function(
  CameraDeviceState state,
  CameraDevice device,
);

class CameraDevice {
  CameraDevice._({
    @required this.id,
    @required int handle,
  })  : _handle = handle,
        assert(id != null),
        assert(handle != null);

  @visibleForTesting
  factory CameraDevice.testMock({
    @required String id,
    @required int handle,
    @required CameraDeviceStateCallback stateCallback,
    @required EventChannel callbackChannel,
  }) {
    final CameraDevice device = CameraDevice._(id: id, handle: handle);
    device._subscription = CameraManager._setUpStateCallbackSubscription(
      callbackChannel: callbackChannel,
      stateCallback: stateCallback,
      device: device,
    );

    return device;
  }

  final int _handle;
  StreamSubscription<dynamic> _subscription;

  final String id;

  Future<CaptureRequest> createCaptureRequest(Template template) async {
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
      template: Template.preview,
      targets: <Surface>[],
    ));
  }

  void createCaptureSession(
    List<Surface> outputs,
    CameraCaptureSessionStateCallback callback,
  ) {
    final CameraCaptureSession session = CameraCaptureSession._(_handle);

    final String stateCallbackChannelName =
        '${Camera.channel}/$CameraCaptureSessionStateCallback/${session._handle}';

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
        'stateCallbackChannelName': stateCallbackChannelName,
        'outputs': outputData,
      },
    ).then((_) {
      session._setUpStateCallbackSubscription(
        stateCallbackChannelName: stateCallbackChannelName,
        stateCallback: callback,
      );
    });
  }

  Future<void> close() {
    _subscription?.cancel();
    return Camera.channel.invokeMethod<void>(
      '$CameraDevice#close',
      <String, dynamic>{'handle': _handle},
    );
  }
}

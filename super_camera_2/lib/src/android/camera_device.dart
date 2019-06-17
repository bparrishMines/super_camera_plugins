part of super_camera;

class CameraDevice extends CameraConfigurator {
  CameraDevice._(this.id) : assert(id != null);

  StreamSubscription<dynamic> _subscription;

  final String id;

  Future<void> close() {
    _subscription?.cancel();
    return null;
  }

  @override
  Future<void> createPreviewTexture() {
    // TODO: implement createPreviewTexture
    return null;
  }

  @override
  Future<void> dispose() => close();

  @override
  // TODO: implement previewTextureId
  int get previewTextureId => null;

  @override
  Future<void> start() {
    // TODO: implement start
    return null;
  }

  @override
  Future<void> stop() {
    // TODO: implement stop
    return null;
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

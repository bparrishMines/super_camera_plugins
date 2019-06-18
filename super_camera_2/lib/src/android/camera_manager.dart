part of super_camera;

class CameraManager {
  CameraManager._();

  static const int _handle = -1;

  static Future<CameraCharacteristics> getCameraCharacteristics(
    String cameraId,
  ) async {
    final Map<String, dynamic> data =
        await Camera.channel.invokeMapMethod<String, dynamic>(
      '$CameraManager#getCameraCharacteristics',
      <String, dynamic>{'cameraId': cameraId, 'handle': _handle},
    );

    return CameraCharacteristics._fromMap(data);
  }

  static Future<List<String>> getCameraIdList() {
    return Camera.channel.invokeListMethod<String>(
      '$CameraManager#getCameraIdList',
      <String, dynamic>{'handle': _handle},
    );
  }

  static void openCamera(
    String cameraId,
    CameraDeviceStateCallback callback,
  ) {
    final CameraDevice device = CameraDevice._(cameraId);

    final String stateCallbackChannelName =
        '${Camera.channel}/$CameraDeviceStateCallback/${device._handle}';

    Camera.channel.invokeMethod<void>(
      '$CameraManager#openCamera',
      <String, dynamic>{
        'handle': _handle,
        'cameraId': cameraId,
        'cameraHandle': device._handle,
        'stateCallbackChannelName': stateCallbackChannelName,
      },
    ).then((_) {
      device._setUpStateCallbackSubscription(
        stateCallbackChannelName: stateCallbackChannelName,
        stateCallback: callback,
      );
    });
  }
}

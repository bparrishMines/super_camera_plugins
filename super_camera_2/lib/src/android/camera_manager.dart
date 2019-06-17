part of super_camera;

typedef CameraDeviceStateCallback = Function(
  CameraDeviceState state,
  CameraDevice device,
);

enum CameraDeviceState { closed, disconnected, error, opened }

class CameraManager {
  CameraManager._();

  static Future<CameraCharacteristics> getCameraCharacteristics(
    String cameraId,
  ) async {
    final Map<String, dynamic> data =
        await Camera.channel.invokeMapMethod<String, dynamic>(
      '$CameraManager#getCameraCharacteristics',
      <String, dynamic>{'cameraId': cameraId},
    );

    return CameraCharacteristics._fromMap(data);
  }

  static Future<List<String>> getCameraIdList() {
    return Camera.channel.invokeListMethod<String>(
      '$CameraManager#getCameraIdList',
    );
  }

  static CameraDevice openCamera(
    String cameraId,
    CameraDeviceStateCallback callback,
  ) {
    final CameraDevice device = CameraDevice._(cameraId);

    final String stateCallbackChannelName =
        '${Camera.channel}/$CameraDeviceStateCallback/${device._handle}';

    Camera.channel.invokeMethod<void>(
      'CameraManager#openCamera',
      <String, dynamic>{
        'cameraId': cameraId,
        'handle': device._handle,
        'stateCallbackChannelName': stateCallbackChannelName,
      },
    ).then((_) {
      device._setUpStateCallbackSubscription(
        stateCallbackChannelName: stateCallbackChannelName,
        stateCallback: callback,
      );
    });

    return device;
  }
}

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

  static void openCamera(String cameraId, CameraDeviceStateCallback callback) {

  }
}

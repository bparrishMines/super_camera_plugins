part of super_camera;

abstract class CaptureInput with _CameraMappable {}

class CaptureDeviceInput implements CaptureInput {
  const CaptureDeviceInput({this.device});

  final CaptureDevice device;
  @override
  Map<String, dynamic> asMap() {
    return null;
  }
}

part of super_camera;

abstract class CaptureOutput with _CameraMappable {}

class CaptureVideoDataOutput implements CaptureOutput {
  CaptureVideoDataOutput({this.delegate});

  final CaptureVideoDataOutputSampleBufferDelegate delegate;

  @override
  Map<String, dynamic> asMap() {
    return null;
  }
}

class CaptureVideoDataOutputSampleBufferDelegate
    with _CameraMappable, _NativeMethodCallHandler {
  CaptureVideoDataOutputSampleBufferDelegate({PlatformTexture texture})
      : _texture = texture;

  final PlatformTexture _texture;

  @override
  Map<String, dynamic> asMap() {
    return null;
  }
}

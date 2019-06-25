part of super_camera;

enum PixelFormatType { bgra32 }

abstract class CaptureOutput with _NativeMethodCallHandler, _CameraMappable {}

class CaptureVideoDataOutput extends CaptureOutput {
  CaptureVideoDataOutput({this.delegate, this.formatType});

  final CaptureVideoDataOutputSampleBufferDelegate delegate;
  final PixelFormatType formatType;

  @override
  Map<String, dynamic> asMap() {
    return <String, dynamic>{
      'handle': _handle,
      'delegate': delegate?.asMap(),
      'formatType': formatType,
    };
  }
}

class CaptureVideoDataOutputSampleBufferDelegate
    with _CameraMappable, _NativeMethodCallHandler {
  CaptureVideoDataOutputSampleBufferDelegate({PlatformTexture texture})
      : _texture = texture;

  final PlatformTexture _texture;

  @override
  Map<String, dynamic> asMap() {
    return <String, dynamic>{
      'handle': _handle,
      'textureHandle': _texture?._handle,
    };
  }
}

part of super_camera;

enum PixelFormatType { bgra32 }

enum _CaptureOutputClass { captureVideoDataOutput }

abstract class CaptureOutput with _NativeMethodCallHandler, _CameraMappable {}

class CaptureVideoDataOutput extends CaptureOutput {
  CaptureVideoDataOutput({this.delegate, this.formatType});

  static const _CaptureOutputClass _outputClass =
      _CaptureOutputClass.captureVideoDataOutput;

  final CaptureVideoDataOutputSampleBufferDelegate delegate;
  final PixelFormatType formatType;

  @override
  Map<String, dynamic> asMap() {
    return <String, dynamic>{
      'handle': _handle,
      'class': _outputClass.toString(),
      'delegate': delegate?.asMap(),
      'formatType': formatType?.toString(),
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

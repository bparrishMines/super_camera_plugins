part of ios_camera;

enum PixelFormatType { bgra32 }

enum _CaptureOutputClass { captureVideoDataOutput }

abstract class CaptureOutput with NativeMethodCallHandler, CameraMappable {}

class CaptureVideoDataOutput extends CaptureOutput {
  CaptureVideoDataOutput({this.delegate, this.formatType});

  static const _CaptureOutputClass _outputClass =
      _CaptureOutputClass.captureVideoDataOutput;

  final CaptureVideoDataOutputSampleBufferDelegate delegate;
  final PixelFormatType formatType;

  @override
  Map<String, dynamic> asMap() {
    return <String, dynamic>{
      'handle': handle,
      'class': _outputClass.toString(),
      'delegate': delegate?.asMap(),
      'formatType': formatType?.toString(),
    };
  }
}

class CaptureVideoDataOutputSampleBufferDelegate
    with CameraMappable, NativeMethodCallHandler {
  CaptureVideoDataOutputSampleBufferDelegate({PlatformTexture texture})
      : _texture = texture;

  final PlatformTexture _texture;

  @override
  Map<String, dynamic> asMap() {
    return <String, dynamic>{
      'handle': handle,
      'platformTexture': _texture?.asMap(),
    };
  }
}

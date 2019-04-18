part of super_camera;

class TextureSettings extends CaptureDelegate {
  TextureSettings({
    @required Function(Texture texture) onTextureReady,
  }) : super(
          androidClassName: _androidName,
          androidClassNameCamera2: _androidNameCamera2,
          iOSClassName: _iOSName,
          onConfigured: (dynamic result) {
            onTextureReady(Texture(textureId: result));
          },
        );

  static const String _androidName =
      'com.example.supercamera.camera.video_delegates.TextureDelegate';
  static const String _androidNameCamera2 =
      'com.example.supercamera.camera2.video_delegates.TextureDelegate';
  static const String _iOSName = 'TextureDelegate';
}

class DataSettings extends CaptureDelegate {
  DataSettings({
    @required Function(Uint8List bytes) onImageDataAvailable,
  }) : super(
          androidClassName: _androidName,
          androidClassNameCamera2: _androidNameCamera2,
          iOSClassName: _iOSName,
          onConfigured: (dynamic result) {
            onImageDataAvailable(result);
          },
        );

  static const String _androidName =
      'com.example.supercamera.camera.photo_delegates.DataDelegate';
  static const String _androidNameCamera2 =
      'com.example.supercamera.camera2.photo_delegates.DataDelegate';
  static const String _iOSName = 'DataDelegate';
}

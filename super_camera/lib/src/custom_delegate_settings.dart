part of super_camera;

class TextureSettings extends CaptureDelegateSettings {
  TextureSettings({
    @required Function(Texture texture) onTextureReady,
    Function(CameraException exception) onFailure,
  }) : super(
          androidDelegateName: _androidName,
          iOSDelegateName: _iOSName,
          onSuccess: (dynamic result) {
            onTextureReady(Texture(textureId: result));
          },
          onFailure: onFailure,
        );

  static const String _androidName =
      'com.example.supercamera.camera1.repeating_capture_delegates.TextureDelegate';
  static const String _iOSName = 'TextureDelegate';
}

class DataSettings extends CaptureDelegateSettings {
  DataSettings({
    @required Function(Uint8List bytes) onImageDataAvailable,
    Function(CameraException exception) onFailure,
  }) : super(
          androidDelegateName: _androidName,
          iOSDelegateName: _iOSName,
          onSuccess: (dynamic result) {
            onImageDataAvailable(result);
          },
          onFailure: onFailure,
        );

  static const String _androidName =
      'com.example.supercamera.camera1.single_capture_delegates.DataDelegate';
  static const String _iOSName = 'DataDelegate';
}

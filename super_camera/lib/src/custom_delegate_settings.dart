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
      'com.example.supercamera.camera1.video_delegates.TextureDelegate';
  static const String _androidNameCamera2 =
      'com.example.supercamera.camera2.video_delegates.TextureDelegate';
  static const String _iOSName = 'TextureDelegate';
}

class DataSettings extends CaptureDelegate {
  DataSettings._({
    Map<String, dynamic> settings,
    Function(dynamic result) onConfigured,
  }) : super(
          androidClassName: _androidName,
          androidClassNameCamera2: _androidNameCamera2,
          iOSClassName: _iOSName,
          onConfigured: onConfigured,
          settings: settings,
        );

  factory DataSettings({
    @required Function(Uint8List bytes) onImageDataAvailable,
  }) {
    final String channelName = '$DataSettings/${_nextHandle++}';

    return DataSettings._(
      settings: <String, dynamic>{
        'channelName': channelName,
      },
      onConfigured: (_) {
        StreamSubscription<dynamic> subscription =
            EventChannel(channelName).receiveBroadcastStream().listen(
          (dynamic event) {
            onImageDataAvailable(event);
          },
        );

        subscription.onDone(() => subscription.cancel());
      },
    );
  }

  static const String _androidName =
      'com.example.supercamera.camera1.photo_delegates.DataDelegate';
  static const String _androidNameCamera2 =
      'com.example.supercamera.camera2.photo_delegates.DataDelegate';
  static const String _iOSName = 'DataDelegate';

  static int _nextHandle = 0;
}

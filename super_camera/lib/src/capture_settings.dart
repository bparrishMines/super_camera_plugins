part of super_camera;

enum VideoOrientation {
  portraitUp,
  portraitDown,
  landscapeRight,
  landscapeLeft,
}

class PhotoSettings {
  const PhotoSettings({@required this.delegateSettings})
      : assert(delegateSettings != null);

  final CaptureDelegateSettings delegateSettings;

  Map<String, dynamic> _serialize() {
    return <String, dynamic>{
      'androidDelegateName': delegateSettings.androidDelegateName,
      'iOSDelegateName': delegateSettings.iOSDelegateName,
      'delegateSettings': delegateSettings.settings,
    };
  }
}

class VideoSettings {
  const VideoSettings({
    @required this.delegateSettings,
    @required this.videoFormat,
    bool shouldMirror,
    VideoOrientation orientation,
  })  : shouldMirror = shouldMirror ?? false,
        orientation = orientation ?? VideoOrientation.portraitUp,
        assert(delegateSettings != null),
        assert(videoFormat != null);

  final CaptureDelegateSettings delegateSettings;
  final VideoFormat videoFormat;

  /// Indicates whether the video should be mirrored about its vertical axis for iOS.
  ///
  /// Defaults to false.
  ///
  /// iOS: Sets
  /// https://developer.apple.com/documentation/avfoundation/avcaptureconnection/1389172-videomirrored?language=objc
  ///
  /// Android: Does nothing. Front facing camera is automatically mirrored by
  /// the system. See
  /// https://developer.android.com/reference/android/hardware/Camera.html#setDisplayOrientation(int)
  final bool shouldMirror;

  // TODO(Maurice): Include information bout VideoOrientation.landscapeRight
  // probably won't work. setDisplayOrientation on Android.
  final VideoOrientation orientation;

  Map<String, dynamic> _serialize() {
    return <String, dynamic>{
      'androidDelegateName': delegateSettings.androidDelegateName,
      'iOSDelegateName': delegateSettings.iOSDelegateName,
      'delegateSettings': delegateSettings.settings,
      'shouldMirror': shouldMirror,
      'videoFormat': videoFormat._serialize(),
      'orientation': orientation.toString(),
    };
  }
}

abstract class CaptureDelegateSettings {
  const CaptureDelegateSettings({
    @required this.androidDelegateName,
    @required this.iOSDelegateName,
    @required this.onSuccess,
    this.onFailure,
    this.settings,
  }) : assert(androidDelegateName != null || iOSDelegateName != null);

  final Function(dynamic result) onSuccess;
  final Function(CameraException exception) onFailure;
  final String androidDelegateName;
  final String iOSDelegateName;
  final Map<String, dynamic> settings;
}

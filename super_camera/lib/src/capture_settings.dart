part of super_camera;

enum VideoOrientation {
  portraitUp,
  portraitDown,
  landscapeRight,
  landscapeLeft,
}

class PhotoSettings {
  const PhotoSettings({@required this.delegate}) : assert(delegate != null);

  final CaptureDelegate delegate;

  Map<String, dynamic> _serialize() {
    return <String, dynamic>{
      'androidClassName': delegate.androidClassName,
      'androidClassNameCamera2': delegate.androidClassNameCamera2,
      'iOSDelegateName': delegate.iOSClassName,
      'delegateSettings': delegate.settings,
    };
  }
}

class VideoSettings {
  const VideoSettings({
    @required this.delegate,
    @required this.videoFormat,
    bool shouldMirror,
    VideoOrientation orientation,
  })  : shouldMirror = shouldMirror ?? false,
        orientation = orientation ?? VideoOrientation.portraitUp,
        assert(delegate != null),
        assert(videoFormat != null);

  final CaptureDelegate delegate;
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

  // TODO(Maurice): Include information about VideoOrientation.landscapeRight
  // probably won't work. setDisplayOrientation on Android.
  final VideoOrientation orientation;

  Map<String, dynamic> _serialize() {
    return <String, dynamic>{
      'androidClassName': delegate.androidClassName,
      'androidClassNameCamera2': delegate.androidClassNameCamera2,
      'iOSClassName': delegate.iOSClassName,
      'delegateSettings': delegate.settings,
      'shouldMirror': shouldMirror,
      'videoFormat': videoFormat._serialize(),
      'orientation': orientation.toString(),
    };
  }
}

abstract class CaptureDelegate {
  const CaptureDelegate({
    @required this.androidClassName,
    @required this.androidClassNameCamera2,
    @required this.iOSClassName,
    @required this.onConfigured,
    this.settings,
  }) : assert(androidClassName != null ||
            iOSClassName != null ||
            androidClassNameCamera2 != null);

  final String androidClassName;
  final String androidClassNameCamera2;
  final String iOSClassName;
  final Function(dynamic result) onConfigured;
  final Map<String, dynamic> settings;
}

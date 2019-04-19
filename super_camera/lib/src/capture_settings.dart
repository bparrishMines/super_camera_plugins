part of super_camera;

enum VideoOrientation {
  portraitUp,
  portraitDown,
  landscapeRight,
  landscapeLeft,
}

class PhotoSettings {
  const PhotoSettings({@required this.delegate}) : assert(delegate != null);

  final PhotoDelegate delegate;

  Map<String, dynamic> _serialize() {
    return <String, dynamic>{
      'androidClassName': delegate.androidClassName,
      'androidClassNameCamera2': delegate.androidClassNameCamera2,
      'iOSClassName': delegate.iOSClassName,
      'delegateSettings': delegate.settings,
    };
  }
}

class PhotoDelegate extends _CaptureDelegate {
  const PhotoDelegate({
    String androidClassName,
    String androidClassNameCamera2,
    String iOSClassName,
    Function(dynamic result) onConfigured,
    Map<String, dynamic> settings,
  }) : super(
    androidClassName: androidClassName,
    androidClassNameCamera2: androidClassNameCamera2,
    iOSClassName: iOSClassName,
    onConfigured: onConfigured,
    settings: settings,
  );
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

  final VideoDelegate delegate;
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

class VideoDelegate extends _CaptureDelegate {
  const VideoDelegate({
    String androidClassName,
    String androidClassNameCamera2,
    String iOSClassName,
    Function(dynamic result) onConfigured,
    Map<String, dynamic> settings,
  }) : super(
          androidClassName: androidClassName,
          androidClassNameCamera2: androidClassNameCamera2,
          iOSClassName: iOSClassName,
          onConfigured: onConfigured,
          settings: settings,
        );
}

abstract class _CaptureDelegate {
  const _CaptureDelegate({
    @required this.androidClassName,
    @required this.androidClassNameCamera2,
    @required this.iOSClassName,
    @required this.onConfigured,
    @required this.settings,
  }) : assert(androidClassName != null ||
            iOSClassName != null ||
            androidClassNameCamera2 != null);

  final String androidClassName;
  final String androidClassNameCamera2;
  final String iOSClassName;
  final Function(dynamic result) onConfigured;
  final Map<String, dynamic> settings;
}

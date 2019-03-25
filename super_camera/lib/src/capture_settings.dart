part of super_camera;

class SingleCaptureSettings {
  const SingleCaptureSettings({@required this.delegateSettings})
      : assert(delegateSettings != null);

  final CaptureDelegateSettings delegateSettings;

  Map<String, dynamic> _serialize() {
    return <String, dynamic>{
      'androidDelegateName': delegateSettings.androidDelegateName,
      'iOSDelegateName': delegateSettings.iOSDelegateName,
      'additionalSettings': delegateSettings.additionalSettings,
    };
  }
}

class RepeatingCaptureSettings {
  const RepeatingCaptureSettings({
    @required this.delegateSettings,
    this.shouldMirror = false,
  })  : assert(delegateSettings != null),
        assert(shouldMirror != null);

  final CaptureDelegateSettings delegateSettings;

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

  Map<String, dynamic> _serialize() {
    return <String, dynamic>{
      'androidDelegateName': delegateSettings.androidDelegateName,
      'iOSDelegateName': delegateSettings.iOSDelegateName,
      'additionalSettings': delegateSettings.additionalSettings,
      'shouldMirror': shouldMirror,
    };
  }
}

abstract class CaptureDelegateSettings {
  const CaptureDelegateSettings({
    @required this.androidDelegateName,
    @required this.iOSDelegateName,
    @required this.onSuccess,
    this.onFailure,
    this.additionalSettings,
  }) : assert(androidDelegateName != null || iOSDelegateName != null);

  final Function(dynamic result) onSuccess;
  final Function(CameraException exception) onFailure;
  final String androidDelegateName;
  final String iOSDelegateName;
  final Map<String, dynamic> additionalSettings;
}

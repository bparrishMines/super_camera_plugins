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
  const RepeatingCaptureSettings({@required this.delegateSettings})
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

part of super_camera;

class SingleCaptureSettings {
  const SingleCaptureSettings({
    @required this.onSuccess,
    this.onFailure,
    this.androidDelegateName,
    this.iOSDelegateName,
    this.additionalSettings,
  });

  final Function(dynamic result) onSuccess;
  final Function(CameraException exception) onFailure;
  final String androidDelegateName;
  final String iOSDelegateName;
  final Map<String, dynamic> additionalSettings;

  Map<String, dynamic> _serialize() {
    return <String, dynamic>{
      'androidDelegateName': androidDelegateName,
      'iOSDelegateName': androidDelegateName,
      'additionalSettings': additionalSettings,
    };
  }
}

class RepeatingCaptureSettings {
  const RepeatingCaptureSettings({
    @required this.onSuccess,
    this.onFailure,
    this.androidDelegateName,
    this.iOSDelegateName,
    this.additionalSettings,
  });

  final Function(dynamic result) onSuccess;
  final Function(CameraException exception) onFailure;
  final String androidDelegateName;
  final String iOSDelegateName;
  final Map<String, dynamic> additionalSettings;

  Map<String, dynamic> _serialize() {
    return <String, dynamic>{
      'androidDelegateName': androidDelegateName,
      'iOSDelegateName': androidDelegateName,
      'additionalSettings': additionalSettings,
    };
  }
}

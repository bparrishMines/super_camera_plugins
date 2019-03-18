part of super_camera;

abstract class SingleCaptureSettings {
  const SingleCaptureSettings({this.onSuccess, this.onFailure});

  final Function onSuccess;
  final Function onFailure;
}

abstract class RepeatingCaptureSettings {
  const RepeatingCaptureSettings({this.onSuccess, this.onFailure});

  final Function onSuccess;
  final Function onFailure;
}

part of super_camera;

enum LensDirection { front, back, external }

class CameraDevice {
  const CameraDevice({@required this.cameraId, @required this.lensDirection});

  final String cameraId;
  final LensDirection lensDirection;
}

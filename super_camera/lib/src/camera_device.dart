part of super_camera;

enum LensDirection { front, back, external }

class CameraDevice {
  const CameraDevice._({
    @required String cameraId,
    @required this.lensDirection,
  }) : _cameraId = cameraId;

  final String _cameraId;
  final LensDirection lensDirection;

  @override
  String toString() => '$runtimeType($lensDirection)';
}

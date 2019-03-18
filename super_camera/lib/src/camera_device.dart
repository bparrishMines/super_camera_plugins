part of super_camera;

enum LensDirection { front, back, external }

class CameraDevice {
  const CameraDevice._({
    @required this.cameraId,
    @required this.lensDirection,
  });

  factory CameraDevice._fromMap(Map<dynamic, dynamic> data) {
    final LensDirection lensDirection = LensDirection.values.firstWhere(
      (LensDirection direction) {
        return direction.toString().endsWith(data['lensDirection']);
      },
    );

    return CameraDevice._(
      cameraId: data['cameraId'],
      lensDirection: lensDirection,
    );
  }

  final String cameraId;
  final LensDirection lensDirection;

  @override
  int get hashCode => cameraId.hashCode ^ lensDirection.hashCode;

  @override
  bool operator ==(other) {
    return cameraId == other.cameraId && lensDirection == other.lensDirection;
  }

  @override
  String toString() => '$runtimeType($cameraId, $lensDirection)';
}

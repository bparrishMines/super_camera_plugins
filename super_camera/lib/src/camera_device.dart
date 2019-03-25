part of super_camera;

enum LensDirection { front, back, external }

class CameraDevice {
  const CameraDevice._({
    @required this.cameraId,
    @required this.lensDirection,
    @required this.orientation,
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
      orientation: data['orientation'],
    );
  }

  final String cameraId;
  final LensDirection lensDirection;

  /// Clockwise angle through which the output image needs to be rotated to be upright on the device screen in its native orientation.
  ///
  /// **Range of valid values:**
  /// 0, 90, 180, 270
  final int orientation;

  @override
  int get hashCode =>
      cameraId.hashCode ^ lensDirection.hashCode ^ orientation.hashCode;

  @override
  bool operator ==(other) {
    return this.hashCode == other.hashCode;
  }

  @override
  String toString() => '$runtimeType($cameraId, $lensDirection, $orientation)';
}

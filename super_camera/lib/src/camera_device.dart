part of super_camera;

enum LensDirection { front, back, external }

class CameraDevice {
  const CameraDevice._({
    @required this.cameraId,
    @required this.lensDirection,
    this.orientation,
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
      orientation: data['orientation']
    );
  }

  final String cameraId;
  final LensDirection lensDirection;

  /// Clockwise angle through which the output image needs to be rotated to be upright on the device screen in its native orientation.
  ///
  /// **Range of valid values:**
  /// 0, 90, 180, 270
  ///
  /// On Android, also defines the direction of rolling shutter readout, which
  /// is from top to bottom in the sensor's coordinate system.
  final int orientation;

  @override
  int get hashCode => cameraId.hashCode ^ lensDirection.hashCode;

  @override
  bool operator ==(other) {
    return cameraId == other.cameraId && lensDirection == other.lensDirection;
  }

  @override
  String toString() => '$runtimeType($cameraId, $lensDirection)';
}

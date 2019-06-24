part of super_camera;

class CaptureDevice implements CameraDescription {
  const CaptureDevice._({this.uniqueId, this.position})
      : assert(uniqueId != null),
        assert(position != null);

  factory CaptureDevice._fromMap(Map<dynamic, dynamic> data) {
    return CaptureDevice._(
      uniqueId: data['uniqueId'],
      position: CaptureDevicePosition.values.firstWhere(
        (CaptureDevicePosition position) {
          return position.toString() == data['position'];
        },
      ),
    );
  }

  final String uniqueId;
  final CaptureDevicePosition position;

  @override
  LensDirection get direction {
    switch (position) {
      case CaptureDevicePosition.front:
        return LensDirection.front;
      case CaptureDevicePosition.back:
        return LensDirection.back;
      case CaptureDevicePosition.unspecified:
        return LensDirection.external;
    }

    return null;
  }

  @override
  get id => uniqueId;
}

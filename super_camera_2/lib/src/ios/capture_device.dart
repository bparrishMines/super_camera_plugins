part of super_camera;

class CaptureDevice
    with _CameraMappable, _NativeMethodCallHandler
    implements CameraDescription {
  CaptureDevice._({this.uniqueId, this.position})
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

  static Future<List<CaptureDevice>> getDevices(MediaType mediaType) async {
    assert(mediaType != null);

    final List<dynamic> deviceData =
        await Camera.channel.invokeListMethod<dynamic>(
      '$CaptureDevice#getDevices',
      <String, dynamic>{'mediaType': mediaType.toString()},
    );

    return deviceData
        .map<CaptureDevice>((dynamic data) => CaptureDevice._fromMap(data))
        .toList();
  }

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

  @override
  Map<String, dynamic> asMap() {
    return <String, dynamic>{'handle': _handle, 'uniqueId': uniqueId};
  }
}

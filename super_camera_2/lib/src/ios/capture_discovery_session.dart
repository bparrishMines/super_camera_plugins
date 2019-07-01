part of ios_camera;

enum CaptureDeviceType { builtInWideAngleCamera }
enum MediaType { video }
enum CaptureDevicePosition { front, back, unspecified }

class CaptureDiscoverySession {
  CaptureDiscoverySession({
    @required List<CaptureDeviceType> deviceTypes,
    @required this.position,
    this.mediaType,
  })  : deviceTypes =
            List<CaptureDeviceType>.unmodifiable(deviceTypes).toList(),
        assert(deviceTypes != null),
        assert(deviceTypes.isNotEmpty),
        assert(position != null);

  final List<CaptureDeviceType> deviceTypes;
  final MediaType mediaType;
  final CaptureDevicePosition position;

  Future<List<CaptureDevice>> get devices async {
    final List<dynamic> deviceData =
        await CameraChannel.channel.invokeListMethod<dynamic>(
      '$CaptureDiscoverySession#devices',
      <String, dynamic>{
        'deviceTypes': deviceTypes
            .map<String>((CaptureDeviceType type) => type.toString())
            .toList(),
        'mediaType': mediaType?.toString(),
        'position': position.toString(),
      },
    );

    return deviceData
        .map<CaptureDevice>((dynamic data) => CaptureDevice._fromMap(data))
        .toList();
  }
}

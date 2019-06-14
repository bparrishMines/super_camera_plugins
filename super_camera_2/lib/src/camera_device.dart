part of super_camera;

enum LensDirection { front, back, external }

class CameraDevice {
  const CameraDevice._({
    @required this.cameraId,
    @required this.lensDirection,
    @required this.orientation,
    @required this.videoFormats,
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
      videoFormats: _videoFormatsFromList(data['videoFormats']),
    );
  }

  final String cameraId;
  final LensDirection lensDirection;

  /// Clockwise angle through which the output image needs to be rotated to be upright on the device screen in its native orientation.
  ///
  /// **Range of valid values:**
  /// 0, 90, 180, 270
  final int orientation;

  final List<VideoFormat> videoFormats;

  static List<VideoFormat> _videoFormatsFromList(List<dynamic> data) {
    return data.map<VideoFormat>(
      (dynamic format) {
        return VideoFormat._(
          dimensions: Size(
            format['width'].toDouble(),
            format['height'].toDouble(),
          ),
          pixelFormat: PixelFormat._fromMap(format['pixelFormat']),
        );
      },
    ).toList();
  }

  @override
  int get hashCode => cameraId.hashCode;

  @override
  bool operator ==(other) => this.hashCode == other.hashCode;

  @override
  String toString() => '''$runtimeType($cameraId, $lensDirection, $orientation,
   $videoFormats)''';
}

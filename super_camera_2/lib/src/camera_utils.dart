part of super_camera;

class CameraUtils {
  CameraUtils._();

  static Future<CameraDevice> cameraDeviceForDirection(
    LensDirection direction,
  ) async {
    final List<CameraDevice> devices = await Camera.availableCameras();
    return devices.firstWhere(
      (CameraDevice device) => device.lensDirection == direction,
      orElse: () => null,
    );
  }

  static VideoFormat bestVideoFormatForAspectRatio({
    @required List<VideoFormat> videoFormats,
    @required double aspectRatio,
    bool largest = true,
  }) {
    assert(videoFormats != null);
    assert(videoFormats.isNotEmpty);
    assert(aspectRatio != null);
    assert(largest != null);

    final List<VideoFormat> sortedVideoFormats = List.from(videoFormats)
      ..sort((VideoFormat one, VideoFormat two) {
        final double areaOne = one.dimensions.width * one.dimensions.height;
        final double areaTwo = two.dimensions.width * two.dimensions.height;

        if (areaOne == areaTwo) return 0;

        if (largest) {
          return areaOne > areaTwo ? -1 : 1;
        } else {
          return areaOne > areaTwo ? 1 : -1;
        }
      });

    VideoFormat bestVideoFormat = sortedVideoFormats[0];

    final Size dimensions = bestVideoFormat.dimensions;
    final double formatAspectRatio = dimensions.width / dimensions.height;

    double smallestDifference = formatAspectRatio - aspectRatio;

    for (int i = 1; i < sortedVideoFormats.length; i++) {
      final Size dimensions = sortedVideoFormats[i].dimensions;
      final double formatAspectRatio = dimensions.width / dimensions.height;

      final double difference = formatAspectRatio - aspectRatio;

      if (smallestDifference.abs() > difference.abs()) {
        bestVideoFormat = sortedVideoFormats[i];
        smallestDifference = difference.abs();

        if (smallestDifference <= .001) break;
      }
    }

    return bestVideoFormat;
  }
}

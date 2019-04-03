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

  static Size bestSizeForAspectRatio(
    List<Size> sizes, {
    double aspectRatio = 16 / 9,
    bool largest = true,
  }) {
    assert(sizes != null);
    assert(aspectRatio != null);
    assert(largest != null);

    final List<Size> sortedSizes = List.from(sizes)
      ..sort((Size one, Size two) {
        final double areaOne = one.width * one.height;
        final double areaTwo = two.width * two.height;

        if (areaOne == areaTwo) return 0;

        if (largest) {
          return areaOne > areaTwo ? -1 : 1;
        } else {
          return areaOne > areaTwo ? 1 : -1;
        }
      });

    Size resolution = sortedSizes[0];
    double closestAspectRatio =
        (resolution.width / resolution.height) - aspectRatio;

    for (int i = 1; i < sortedSizes.length; i++) {
      final double difference =
          (sortedSizes[i].width / sortedSizes[i].height) - aspectRatio;

      if (closestAspectRatio.abs() > difference.abs()) {
        resolution = sortedSizes[i];
        closestAspectRatio = difference.abs();
      }
    }

    return resolution;
  }
}

part of android_camera;

abstract class Surface with CameraMappable {}

class PreviewTexture implements Surface {
  const PreviewTexture({
    @required this.platformTexture,
    @required this.surfaceTexture,
  })  : assert(platformTexture != null),
        assert(surfaceTexture != null);

  final PlatformTexture platformTexture;
  final SurfaceTexture surfaceTexture;

  @override
  Map<String, dynamic> asMap() {
    return Map.unmodifiable(<String, dynamic>{
      'surfaceClass': '$PreviewTexture',
      'platformTexture': platformTexture.asMap(),
      'surfaceTexture': surfaceTexture.asMap(),
    });
  }
}

class SurfaceTexture with CameraMappable {
  const SurfaceTexture({this.defaultBufferSize});

  final Size defaultBufferSize;

  @override
  Map<String, dynamic> asMap() {
    return Map.unmodifiable(<String, dynamic>{
      'width': defaultBufferSize?.width?.toInt(),
      'height': defaultBufferSize?.height?.toInt(),
    });
  }
}

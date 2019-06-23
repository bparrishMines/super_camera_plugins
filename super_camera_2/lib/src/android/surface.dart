part of super_camera;

abstract class Surface {
  Map<String, dynamic> asMap();
}

class PreviewTexture implements Surface {
  const PreviewTexture({
    @required this.platformTexture,
    @required this.surfaceTexture,
  })  : assert(platformTexture != null),
        assert(surfaceTexture != null);

  final PlatformTexture platformTexture;
  final SurfaceTexture surfaceTexture;

  Map<String, dynamic> asMap() {
    return Map.unmodifiable(<String, dynamic>{
      'surfaceClass': '$PreviewTexture',
      'textureHandle': platformTexture._handle,
      '$SurfaceTexture': surfaceTexture.asMap(),
    });
  }
}

class SurfaceTexture {
  const SurfaceTexture({this.defaultBufferSize});

  final Size defaultBufferSize;

  Map<String, dynamic> asMap() {
    return Map.unmodifiable(<String, dynamic>{
      'width': defaultBufferSize?.width?.toInt(),
      'height': defaultBufferSize?.height?.toInt(),
    });
  }
}
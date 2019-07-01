part of android_camera;

abstract class Surface with CameraMappable {}

class PreviewTexture implements Surface {
  const PreviewTexture({
    @required this.nativeTexture,
    @required this.surfaceTexture,
  })  : assert(nativeTexture != null),
        assert(surfaceTexture != null);

  final NativeTexture nativeTexture;
  final SurfaceTexture surfaceTexture;

  @override
  Map<String, dynamic> asMap() {
    return Map.unmodifiable(<String, dynamic>{
      'surfaceClass': '$PreviewTexture',
      'nativeTexture': nativeTexture.asMap(),
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

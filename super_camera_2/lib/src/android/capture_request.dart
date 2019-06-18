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

class CaptureRequest {
  const CaptureRequest._({
    @required this.template,
    @required this.targets,
    this.jpegQuality,
  })  : assert(template != null),
        assert(targets != null),
        assert(jpegQuality == null || (jpegQuality >= 1 && jpegQuality <= 100));

  factory CaptureRequest._fromMap({
    @required Template template,
    @required Map<String, dynamic> map,
  }) {
    return CaptureRequest._(
      template: template,
      jpegQuality: map['jpeqQuality'],
      targets: List.unmodifiable(<Surface>[]),
    );
  }

  final Template template;
  final List<Surface> targets;
  final int jpegQuality;

  CaptureRequest copyWith({List<Surface> targets, int jpegQuality}) {
    return CaptureRequest._(
      template: template,
      jpegQuality: jpegQuality ?? this.jpegQuality,
      targets: List.unmodifiable(targets ?? this.targets),
    );
  }

  Map<String, dynamic> asMap() {
    final List<Map<String, dynamic>> outputData = targets
        .map<Map<String, dynamic>>((Surface surface) => surface.asMap())
        .toList();

    return Map.unmodifiable(<String, dynamic>{
      '$Template': template.toString(),
      'jpegQuality': jpegQuality,
      'targets': outputData,
    });
  }
}

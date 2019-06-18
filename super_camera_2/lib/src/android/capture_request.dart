part of super_camera;

abstract class Surface {
  Map<String, dynamic> asMap();
}

class PreviewTexture implements Surface {
  const PreviewTexture(this.surfaceTexture);

  final SurfaceTexture surfaceTexture;

  Map<String, dynamic> asMap() {
    return Map.unmodifiable(<String, dynamic>{
      'surfaceType': '$PreviewTexture',
      '$SurfaceTexture': surfaceTexture.asMap(),
    });
  }
}

class SurfaceTexture {
  const SurfaceTexture._({this.defaultBufferSize});

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
    @required this.jpegQuality,
    @required this.targets,
  })  : assert(template != null),
        assert(jpegQuality >= 1 && jpegQuality <= 100),
        assert(targets != null);

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
  final int jpegQuality;
  final List<Surface> targets;

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

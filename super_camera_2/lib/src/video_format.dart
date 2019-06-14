part of super_camera;

class VideoFormat {
  const VideoFormat._({@required this.dimensions, @required this.pixelFormat});

  final Size dimensions;
  final PixelFormat pixelFormat;

  Map<String, dynamic> _serialize() => <String, dynamic>{
        'width': dimensions.width,
        'height': dimensions.height,
        'pixelFormat': defaultTargetPlatform == TargetPlatform.iOS
            ? pixelFormat.rawIos
            : pixelFormat.rawAndroid,
      };

  @override
  String toString() {
    return '$runtimeType($dimensions, $pixelFormat)';
  }
}

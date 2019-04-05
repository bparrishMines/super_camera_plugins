part of super_camera;

class PixelFormat {
  const PixelFormat._({@required this.rawAndroid, @required this.rawIos});

  factory PixelFormat._fromMap(Map<dynamic, dynamic> map) {
    return values.firstWhere(
      (PixelFormat format) {
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          return format.rawIos == map['rawIos'];
        } else if (defaultTargetPlatform == TargetPlatform.android) {
          return format.rawAndroid == map['rawAndroid'];
        }

        throw ArgumentError('$defaultTargetPlatform is not supported.');
      },
      orElse: () {
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          return PixelFormat._(rawAndroid: map['rawAndroid'], rawIos: null);
        }

        return PixelFormat._(rawAndroid: null, rawIos: map['rawIod']);
      },
    );
  }

  static const PixelFormat bgra8888 = PixelFormat._(
    rawAndroid: null,
    rawIos: 'BGRA',
  );

  static const PixelFormat yuv420 = PixelFormat._(
    rawAndroid: 35,
    rawIos: '420v',
  );

  final int rawAndroid;
  final String rawIos;

  static List<PixelFormat> get values => <PixelFormat>[bgra8888, yuv420];
}

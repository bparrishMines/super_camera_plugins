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
          return PixelFormat._(rawAndroid: null, rawIos: map['rawIos']);
        }

        return PixelFormat._(rawAndroid: map['rawAndroid'], rawIos: null);
      },
    );
  }

  static const PixelFormat bgra8888 = PixelFormat._(
    rawAndroid: null,
    rawIos: 'BGRA',
  );

  static const PixelFormat yuv420f = PixelFormat._(
    rawAndroid: null,
    rawIos: '420f',
  );

  final int rawAndroid;
  final String rawIos;

  static List<PixelFormat> get values => <PixelFormat>[bgra8888, yuv420f];

  @override
  String toString() {
    return '$runtimeType(android: $rawAndroid, ios: $rawIos)';
  }
}

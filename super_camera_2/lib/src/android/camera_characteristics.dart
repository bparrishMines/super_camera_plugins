part of android_camera;

enum CameraCharacteristicKey { lensFacing, sensorOrientation }
enum LensFacing { front, back, external }

class CameraCharacteristics implements CameraDescription {
  CameraCharacteristics._({this.id, this.lensFacing, this.sensorOrientation})
      : assert(id != null),
        assert(lensFacing != null),
        assert(sensorOrientation != null);

  factory CameraCharacteristics._fromMap(Map<String, dynamic> map) {
    return CameraCharacteristics._(
      id: map['id'],
      sensorOrientation: map['sensorOrientation'],
      lensFacing: LensFacing.values.firstWhere(
        (LensFacing facing) => facing.toString() == map['lensFacing'],
      ),
    );
  }

  final String id;
  final LensFacing lensFacing;
  final int sensorOrientation;

  @override
  LensDirection get direction {
    switch (lensFacing) {
      case LensFacing.front:
        return LensDirection.front;
      case LensFacing.back:
        return LensDirection.back;
      case LensFacing.external:
        return LensDirection.external;
    }

    return null;
  }
}

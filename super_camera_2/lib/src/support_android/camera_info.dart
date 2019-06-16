part of super_camera;

enum Facing { back, front }

class CameraInfo implements CameraDescription {
  const CameraInfo._({this.id, this.facing})
      : assert(id != null),
        assert(facing != null);

  factory CameraInfo._fromMap(Map<String, dynamic> map) {
    return CameraInfo._(id: map['id'], facing: map['$Facing']);
  }

  final int id;
  final Facing facing;

  @override
  LensDirection get direction {
    switch (facing) {
      case Facing.front:
        return LensDirection.front;
      case Facing.back:
        return LensDirection.back;
    }

    throw StateError('Unsupported $Facing');
  }
}
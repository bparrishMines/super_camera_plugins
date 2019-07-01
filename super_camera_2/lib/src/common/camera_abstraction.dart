enum CameraApi { android, iOS, supportAndroid }
enum LensDirection { front, back, external }

abstract class CameraDescription {
  LensDirection get direction;
  dynamic get id;
}

abstract class CameraConfigurator {
  int get previewTextureId;
  Future<void> start();
  Future<void> stop();
  Future<void> dispose();
  Future<void> addPreviewTexture();
}
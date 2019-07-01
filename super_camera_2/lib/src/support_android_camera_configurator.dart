import 'dart:async';

import '../support_android_camera.dart';
import 'common/camera_abstraction.dart';
import 'common/camera_mixins.dart';
import 'common/native_texture.dart';

class SupportAndroidCameraConfigurator
    with CameraClosable
    implements CameraConfigurator {
  SupportAndroidCameraConfigurator(this.info) : assert(info != null) {
    _camera = SupportAndroidCamera.open(info.id);
  }

  NativeTexture _texture;
  SupportAndroidCamera _camera;

  final CameraInfo info;

  SupportAndroidCamera get camera => _camera;

  @override
  Future<void> addPreviewTexture() async {
    assert(!isClosed);
    if (_texture == null) _texture = await NativeTexture.allocate();
    _camera.previewTexture = _texture;
  }

  @override
  Future<void> dispose() {
    isClosed = true;

    Completer<void> completer = Completer<void>();

    _camera
        .release()
        .then((_) => _texture?.release())
        .then((_) => completer.complete());

    return completer.future;
  }

  @override
  int get previewTextureId => _texture?.textureId;

  @override
  Future<void> start() {
    assert(!isClosed);
    return _camera.startPreview();
  }

  @override
  Future<void> stop() {
    return _camera.stopPreview();
  }
}

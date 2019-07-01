import 'dart:async';

import '../android_camera.dart';
import 'common/camera_abstraction.dart';
import 'common/camera_mixins.dart';
import 'common/native_texture.dart';

class AndroidCameraConfigurator
    with CameraClosable
    implements CameraConfigurator {
  AndroidCameraConfigurator(this.characteristics)
      : assert(characteristics != null) {
    CameraManager.instance.openCamera(
      characteristics.id,
      (CameraDeviceState state, CameraDevice device) async {
        _device = device;
        _deviceCallbackCompleter.complete();
      },
    );
  }

  final Completer<void> _deviceCallbackCompleter = Completer<void>();

  NativeTexture _texture;
  CameraDevice _device;
  CameraCaptureSession _session;
  final List<Surface> _outputs = <Surface>[];
  CaptureRequest _previewCaptureRequest;

  final CameraCharacteristics characteristics;

  @override
  Future<void> addPreviewTexture() async {
    assert(!isClosed);

    await _deviceCallbackCompleter.future;

    if (_texture != null) return Future<void>.value();

    _texture = await NativeTexture.allocate();
    final CaptureRequest request = _device.createCaptureRequest(
      Template.preview,
    );

    final PreviewTexture previewTexture = PreviewTexture(
      nativeTexture: _texture,
      surfaceTexture: SurfaceTexture(),
    );

    _outputs.add(previewTexture);

    _previewCaptureRequest = request.copyWith(
      targets: _outputs,
    );
  }

  @override
  Future<void> dispose() {
    if (isClosed) return Future<void>.value();
    isClosed = true;

    Completer<void> completer = Completer<void>();

    if (!_deviceCallbackCompleter.isCompleted) {
      _deviceCallbackCompleter.future
          .then((_) => stop())
          .then((_) => _device.close())
          .then((_) => _texture?.release())
          .then((_) => completer.complete());
    } else {
      stop()
          .then((_) => _device.close())
          .then((_) => _texture?.release())
          .then((_) => completer.complete());
    }

    return completer.future;
  }

  @override
  int get previewTextureId => _texture?.textureId;

  @override
  Future<void> start() async {
    assert(!isClosed);

    await _deviceCallbackCompleter.future;

    final Completer<void> completer = Completer<void>();

    _device.createCaptureSession(
      _outputs,
      (CameraCaptureSessionState state, CameraCaptureSession session) {
        _session = session;
        if (state == CameraCaptureSessionState.configured) {
          session.setRepeatingRequest(request: _previewCaptureRequest);
        }
        completer.complete();
      },
    );

    return completer.future;
  }

  @override
  Future<void> stop() async {
    await _deviceCallbackCompleter.future;

    final CameraCaptureSession tmpSess = _session;
    _session = null;

    return tmpSess?.close();
  }
}

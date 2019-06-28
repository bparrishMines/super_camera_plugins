part of super_camera;

mixin _NativeMethodCallHandler {
  final int _handle = Camera.nextHandle++;
}

mixin _CameraMappable {
  Map<String, dynamic> asMap();
}

mixin _CameraClosable {
  bool _isClosed = false;
}

class PlatformTexture with _CameraClosable {
  PlatformTexture._({@required int handle, @required this.textureId})
      : _handle = handle,
        assert(handle != null),
        assert(textureId != null);

  final int _handle;
  final int textureId;

  Future<void> release() {
    if (_isClosed) return Future<void>.value();

    _isClosed = true;
    return Camera.channel.invokeMethod<void>(
      '$PlatformTexture#release',
      <String, dynamic>{'handle': _handle},
    );
  }
}

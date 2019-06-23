part of super_camera;

mixin _NativeMethodCallHandler {
  final int _handle = Camera.nextHandle++;
  bool _isClosed = false;
}

class PlatformTexture {
  PlatformTexture._({@required int handle, @required this.textureId})
      : _handle = handle,
        assert(handle != null),
        assert(textureId != null);

  final int _handle;
  final int textureId;

  bool _isClosed = false;

  Future<void> release() {
    if (_isClosed) return Future<void>.value();

    _isClosed = true;
    return Camera.channel.invokeMethod<void>(
      '$PlatformTexture#release',
      <String, dynamic>{'handle': _handle},
    );
  }
}

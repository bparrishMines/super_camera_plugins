part of super_camera;

mixin _NativeMethodCallHandler {
  final int _handle = Camera.nextHandle++;
  bool _isClosed = false;
}

class PlatformTexture {
  const PlatformTexture._({@required int handle, @required this.textureId})
      : _handle = handle,
        assert(handle != null),
        assert(textureId != null);

  final int _handle;
  final int textureId;

  Future<void> release() {
    return Camera.channel.invokeMethod<void>(
      '$PlatformTexture#release',
      <String, dynamic>{'handle': _handle},
    );
  }
}

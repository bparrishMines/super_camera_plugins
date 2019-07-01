part of super_camera;

class PlatformTexture with CameraClosable, CameraMappable {
  PlatformTexture._({@required int handle, @required this.textureId})
      : _handle = handle,
        assert(handle != null),
        assert(textureId != null);

  final int _handle;
  final int textureId;

  Future<void> release() {
    if (isClosed) return Future<void>.value();

    isClosed = true;
    return CameraChannel.channel.invokeMethod<void>(
      '$PlatformTexture#release',
      <String, dynamic>{'handle': _handle},
    );
  }

  @override
  Map<String, dynamic> asMap() {
    return <String, dynamic>{'handle': _handle};
  }
}

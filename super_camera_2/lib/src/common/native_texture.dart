import 'package:flutter/foundation.dart';

import 'camera_channel.dart';
import 'camera_mixins.dart';

class NativeTexture with CameraClosable, CameraMappable {
  NativeTexture._({@required int handle, @required this.textureId})
      : _handle = handle,
        assert(handle != null),
        assert(textureId != null);

  final int _handle;
  final int textureId;

  static Future<NativeTexture> allocate() async {
    final int handle = CameraChannel.nextHandle++;

    final int textureId = await CameraChannel.channel.invokeMethod<int>(
      '$NativeTexture#allocate',
      <String, dynamic>{'textureHandle': handle},
    );

    return NativeTexture._(handle: handle, textureId: textureId);
  }

  Future<void> release() {
    if (isClosed) return Future<void>.value();

    isClosed = true;
    return CameraChannel.channel.invokeMethod<void>(
      '$NativeTexture#release',
      <String, dynamic>{'handle': _handle},
    );
  }

  @override
  Map<String, dynamic> asMap() {
    return <String, dynamic>{'handle': _handle};
  }
}

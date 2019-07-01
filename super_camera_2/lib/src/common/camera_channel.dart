import 'package:flutter/services.dart';

typedef CameraCallback = void Function(dynamic result);

class CameraChannel {
  static final Map<int, dynamic> callbacks = <int, CameraCallback>{};

  static final MethodChannel channel = MethodChannel(
    'dev.plugins/super_camera',
  )..setMethodCallHandler(
      (MethodCall call) async {
        assert(call.method == 'handleCallback');

        final int handle = call.arguments['handle'];
        if (callbacks[handle] != null) callbacks[handle](call.arguments);
      },
    );

  static int nextHandle = 0;

  static void registerCallback(int handle, CameraCallback callback) {
    assert(handle != null);
    assert(CameraCallback != null);

    assert(!callbacks.containsKey(handle));
    callbacks[handle] = callback;
  }

  static void unregisterCallback(int handle) {
    assert(handle != null);
    callbacks.remove(handle);
  }
}

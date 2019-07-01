import 'camera_channel.dart';

mixin NativeMethodCallHandler {
  final int handle = CameraChannel.nextHandle++;
}

mixin CameraMappable {
  Map<String, dynamic> asMap();
}

mixin CameraClosable {
  bool isClosed = false;
}
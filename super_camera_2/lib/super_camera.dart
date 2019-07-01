library super_camera;

import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'src/common/camera_channel.dart';
import 'src/common/camera_mixins.dart';
import 'android_camera.dart';
import 'ios_camera.dart';
import 'support_android_camera.dart';

part 'src/camera.dart';
part 'src/camera_abstraction.dart';
part 'src/camera_controller.dart';
part 'src/camera_preview.dart';
part 'src/platform_texture.dart';

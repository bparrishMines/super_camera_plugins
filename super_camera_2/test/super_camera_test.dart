import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_camera/src/camera_testing.dart';
import 'package:super_camera/src/common/native_texture.dart';

void main() {
  group('SuperCamera', () {
    final List<MethodCall> log = <MethodCall>[];

    setUpAll(() {
      CameraTesting.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'NativeTexture#allocate':
            return 15;
        }

        throw ArgumentError.value(
          methodCall.method,
          'methodCall.method',
          'No method found for',
        );
      });
    });

    setUp(() {
      log.clear();
      CameraTesting.nextHandle = 0;
    });

    test('createPlatformTexture', () async {
      final NativeTexture texture = await NativeTexture.allocate();

      expect(texture.textureId, 15);
      expect(log, <Matcher>[
        isMethodCall(
          '$NativeTexture#allocate',
          arguments: <String, dynamic>{'textureHandle': 0},
        )
      ]);
    });
  });
}

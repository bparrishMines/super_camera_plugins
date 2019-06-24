import 'package:flutter/services.dart';
import 'package:super_camera/super_camera.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$Camera', () {
    final List<MethodCall> log = <MethodCall>[];

    setUpAll(() {
      Camera.channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'Camera#createPlatformTexture':
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
      Camera.nextHandle = 0;
    });

    test('createPlatformTexture', () async {
      final PlatformTexture texture = await Camera.createPlatformTexture();

      expect(texture.textureId, 15);
      expect(log, <Matcher>[
        isMethodCall(
          '$Camera#createPlatformTexture',
          arguments: <String, dynamic>{'textureHandle': 0},
        )
      ]);
    });
  });
}

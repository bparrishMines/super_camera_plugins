import 'package:flutter/services.dart';
import 'package:super_camera/super_camera.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$CameraManager', () {
    final List<MethodCall> log = <MethodCall>[];
    setUpAll(() {
      Camera.channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'CameraManager()':
            return null;
          case 'CameraManager#getCameraCharacteristics':
            return <dynamic, dynamic>{
              'id': 'apple',
              'sensorOrientation': 90,
              '$LensFacing': LensFacing.back.toString(),
            };
          case 'CameraManager#getCameraIdList':
            return <dynamic>['1', '2', '3'];
          case 'CameraManager#openCamera':
            return null;
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

    test('instance', () {
      CameraManager.instance;

      expect(log, <Matcher>[
        isMethodCall(
          '$CameraManager()',
          arguments: <String, dynamic>{'managerHandle': 0},
        )
      ]);
    });

    test('getCameraCharacteristics', () async {
      final CameraCharacteristics characteristics =
          await CameraManager.instance.getCameraCharacteristics('hello');

      expect(characteristics.id, 'apple');
      expect(characteristics.sensorOrientation, 90);
      expect(characteristics.lensFacing, LensFacing.back);
      expect(log, <Matcher>[
        isMethodCall(
          '$CameraManager#getCameraCharacteristics',
          arguments: <String, dynamic>{'cameraId': 'hello', 'handle': 0},
        )
      ]);
    });

    test('getCameraIdList', () async {
      final List<String> ids = await CameraManager.instance.getCameraIdList();

      expect(ids, <String>['1', '2', '3']);
      expect(log, <Matcher>[
        isMethodCall(
          '$CameraManager#getCameraIdList',
          arguments: <String, dynamic>{'handle': 0},
        )
      ]);
    });

    test('openCamera', () async {
      CameraManager.instance.openCamera(
        'hello',
        (CameraDeviceState state, CameraDevice device) {
          print(state);
        },
      );

      expect(log, <Matcher>[
        isMethodCall(
          '$CameraManager#openCamera',
          arguments: <String, dynamic>{
            'handle': 0,
            'cameraId': 'hello',
            'cameraHandle': 0,
          },
        )
      ]);

      await defaultBinaryMessenger.handlePlatformMessage(
        Camera.channel.name,
        Camera.channel.codec.encodeMethodCall(
          MethodCall(
            'handleCallback',
            <dynamic, dynamic>{
              'handle': 0,
              '$CameraDeviceState': CameraDeviceState.opened.toString()
            },
          ),
        ),
        (ByteData reply) {},
      );
    });
  });
}

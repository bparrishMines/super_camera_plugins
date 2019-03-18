import 'package:flutter/services.dart';
import 'package:super_camera/super_camera.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$Camera', () {
    final List<MethodCall> log = <MethodCall>[];
    dynamic returnValue;

    setUp(() {
      Camera.channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);

        switch (methodCall.method) {
          case 'Camera#availableCameras':
            return returnValue;
          default:
            return null;
        }
      });
      log.clear();
    });

    test('availableCameras', () async {
      returnValue = <dynamic>[
        <dynamic, dynamic>{
          'cameraId': '23',
          'lensDirection': 'front',
        },
        <dynamic, dynamic>{
          'cameraId': '46',
          'lensDirection': 'back',
        },
        <dynamic, dynamic>{
          'cameraId': '92',
          'lensDirection': 'external',
        },
      ];

      final List<CameraDevice> cameras = await Camera.availableCameras();
      expect(cameras.length, 3);

      expect(cameras[0].cameraId, '23');
      expect(cameras[0].lensDirection, LensDirection.front);

      expect(cameras[1].cameraId, '46');
      expect(cameras[1].lensDirection, LensDirection.back);

      expect(cameras[2].cameraId, '92');
      expect(cameras[2].lensDirection, LensDirection.external);
    });
  });
}

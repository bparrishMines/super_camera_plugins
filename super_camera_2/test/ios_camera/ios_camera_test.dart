import 'package:flutter/services.dart';
import 'package:super_camera/super_camera.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('iOS Camera', () {
    final List<MethodCall> log = <MethodCall>[];

    setUpAll(() {
      Camera.channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'CaptureDevice#getDevices':
          case 'CaptureDiscoverySession#devices':
            return <Map<dynamic, dynamic>>[
              <dynamic, dynamic>{
                'uniqueId': 'apple',
                'position': CaptureDevicePosition.back.toString(),
              },
              <dynamic, dynamic>{
                'uniqueId': 'banana',
                'position': CaptureDevicePosition.unspecified.toString(),
              }
            ];
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

    group('$CaptureDiscoverySession', () {
      test('devices', () async {
        final CaptureDiscoverySession session = CaptureDiscoverySession(
          deviceTypes: <CaptureDeviceType>[
            CaptureDeviceType.builtInWideAngleCamera
          ],
          position: CaptureDevicePosition.front,
          mediaType: MediaType.video,
        );

        final List<CaptureDevice> devices = await session.devices;

        expect(log, <Matcher>[
          isMethodCall(
            '$CaptureDiscoverySession#devices',
            arguments: <String, dynamic>{
              'deviceTypes': <String>[
                CaptureDeviceType.builtInWideAngleCamera.toString()
              ],
              'mediaType': MediaType.video.toString(),
              'position': CaptureDevicePosition.front.toString(),
            },
          )
        ]);

        expect(devices, hasLength(2));
        expect(devices[0].uniqueId, 'apple');
        expect(devices[0].position, CaptureDevicePosition.back);
        expect(devices[0].direction, LensDirection.back);
        expect(devices[1].uniqueId, 'banana');
        expect(devices[1].position, CaptureDevicePosition.unspecified);
        expect(devices[1].direction, LensDirection.external);
      });
    });

    group('$CaptureDevice', () {
      test('getDevices', () async {
        final List<CaptureDevice> devices = await CaptureDevice.getDevices(
          MediaType.video,
        );

        expect(log, <Matcher>[
          isMethodCall(
            '$CaptureDevice#getDevices',
            arguments: <String, dynamic>{
              'mediaType': MediaType.video.toString(),
            },
          )
        ]);

        expect(devices, hasLength(2));
        expect(devices[0].uniqueId, 'apple');
        expect(devices[0].position, CaptureDevicePosition.back);
        expect(devices[0].direction, LensDirection.back);
        expect(devices[1].uniqueId, 'banana');
        expect(devices[1].position, CaptureDevicePosition.unspecified);
        expect(devices[1].direction, LensDirection.external);
      });
    });
  });
}

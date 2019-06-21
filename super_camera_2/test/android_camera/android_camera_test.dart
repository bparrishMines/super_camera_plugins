import 'package:flutter/services.dart';
import 'package:super_camera/super_camera.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AndroidCamera', () {
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
          case 'CameraDevice#close':
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

    group('$CameraManager', () {
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
        CameraDevice cameraDevice;
        CameraManager.instance.openCamera(
          'hello',
          (CameraDeviceState state, CameraDevice device) {
            cameraDevice = device;
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

        await _makeCallback(
          <dynamic, dynamic>{
            'handle': 0,
            '$CameraDeviceState': CameraDeviceState.opened.toString(),
          },
        );

        expect(cameraDevice.id, 'hello');
        cameraDevice.close();
      });
    });

    group('$CameraDeviceState', () {
      test('all states are handled', () async {
        final Map<CameraDeviceState, bool> isCalled =
            Map<CameraDeviceState, bool>.fromIterables(
          CameraDeviceState.values,
          List<bool>.filled(CameraDeviceState.values.length, false),
        );

        CameraDevice cameraDevice;

        CameraManager.instance.openCamera(
          '',
          (CameraDeviceState state, CameraDevice device) {
            cameraDevice = device;
          },
        );

        CameraManager.instance.openCamera(
          '',
          (CameraDeviceState state, CameraDevice device) {
            cameraDevice = device;
          },
        );

        for (CameraDeviceState state in CameraDeviceState.values) {
          isCalled[state] = true;
          await _makeCallback(<dynamic, dynamic>{
            'handle': 0,
            '$CameraDeviceState': state.toString()
          });
        }

        cameraDevice.close();
        expect(isCalled.values, everyElement(isTrue));
      });
    });

    group('$CameraDevice', () {
      CameraDevice cameraDevice;

      setUpAll(() async {
        Camera.nextHandle = 0;
        CameraManager.instance.openCamera(
          '',
          (CameraDeviceState state, CameraDevice device) {
            cameraDevice = device;
          },
        );

        await _makeCallback(<dynamic, dynamic>{
          'handle': 0,
          '$CameraDeviceState': CameraDeviceState.opened.toString()
        });

        assert(cameraDevice != null);
      });

      tearDownAll(() {
        cameraDevice.close();
      });

      test('createCaptureRequest', () async {
        final CaptureRequest request = await cameraDevice.createCaptureRequest(
          Template.preview,
        );

        expect(request.template, Template.preview);
        expect(request.targets, isEmpty);
        expect(request.jpegQuality, isNull);
      });

      test('close', () {
        cameraDevice.close();

        expect(log, <Matcher>[
          isMethodCall(
            '$CameraDevice#close',
            arguments: <String, dynamic>{'handle': 0},
          )
        ]);
      });
    });
  });
}

Future<void> _makeCallback(dynamic arguments) {
  return defaultBinaryMessenger.handlePlatformMessage(
    Camera.channel.name,
    Camera.channel.codec.encodeMethodCall(
      MethodCall('handleCallback', arguments),
    ),
    (ByteData reply) {},
  );
}

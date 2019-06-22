import 'package:flutter/services.dart';
import 'package:super_camera/super_camera.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Android Camera', () {
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
          case 'CameraDevice#createCaptureSession':
            return null;
          case 'Camera#createPlatformTexture':
            return 15;
          case 'CameraCaptureSession#close':
            return null;
          case 'CameraCaptureSession#setRepeatingRequest':
            return null;
        }

        throw ArgumentError.value(
          methodCall.method,
          'methodCall.method',
          'Method not found in test mock method call handler',
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
            expect(state, CameraDeviceState.opened);
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

      test('createCaptureSession', () async {
        final PlatformTexture platformTexture =
            await Camera.createPlatformTexture();
        final SurfaceTexture surfaceTexture = SurfaceTexture();
        final PreviewTexture previewTexture = PreviewTexture(
          platformTexture: platformTexture,
          surfaceTexture: surfaceTexture,
        );

        log.clear();
        Camera.nextHandle = 1;

        CameraCaptureSession captureSession;
        cameraDevice.createCaptureSession(
          <Surface>[previewTexture],
          (CameraCaptureSessionState state, CameraCaptureSession session) {
            expect(state, CameraCaptureSessionState.configured);
            captureSession = session;
          },
        );

        await _makeCallback(<dynamic, dynamic>{
          'handle': 1,
          '$CameraCaptureSessionState':
              CameraCaptureSessionState.configured.toString(),
        });

        expect(log, <Matcher>[
          isMethodCall(
            '$CameraDevice#createCaptureSession',
            arguments: <String, dynamic>{
              'handle': 0,
              'sessionHandle': 1,
              'outputs': <Map<dynamic, dynamic>>[previewTexture.asMap()],
            },
          )
        ]);

        captureSession.close();
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

    group('$CameraCaptureSession', () {
      CameraDevice cameraDevice;
      CameraCaptureSession captureSession;

      setUpAll(() async {
        Camera.nextHandle = 1;

        CameraManager.instance.openCamera(
          '',
          (CameraDeviceState state, CameraDevice device) {
            cameraDevice = device;
          },
        );

        await _makeCallback(<dynamic, dynamic>{
          'handle': 1,
          '$CameraDeviceState': CameraDeviceState.opened.toString(),
        });

        final PlatformTexture platformTexture =
            await Camera.createPlatformTexture();
        final SurfaceTexture surfaceTexture = SurfaceTexture();
        final PreviewTexture previewTexture = PreviewTexture(
          platformTexture: platformTexture,
          surfaceTexture: surfaceTexture,
        );

        Camera.nextHandle = 0;
        cameraDevice.createCaptureSession(
          <Surface>[previewTexture],
          (CameraCaptureSessionState state, CameraCaptureSession session) {
            captureSession = session;
          },
        );

        await _makeCallback(<dynamic, dynamic>{
          'handle': 0,
          '$CameraCaptureSessionState':
              CameraCaptureSessionState.configured.toString(),
        });

        assert(captureSession != null);
      });

      tearDownAll(() {
        cameraDevice.close();
        captureSession.close();
      });

      test('setRepeatingRequest', () async {
        final CaptureRequest request = await cameraDevice.createCaptureRequest(
          Template.preview,
        );

        captureSession.setRepeatingRequest(request: request);

        expect(log, <Matcher>[
          isMethodCall(
            '$CameraCaptureSession#setRepeatingRequest',
            arguments: <String, dynamic>{
              'handle': 0,
              'cameraDeviceHandle': 1,
              '$CaptureRequest': request.asMap(),
            },
          ),
        ]);
      });

      test('close', () {
        captureSession.close();

        expect(log, <Matcher>[
          isMethodCall(
            '$CameraCaptureSession#close',
            arguments: <String, dynamic>{'handle': 0},
          ),
        ]);
      });
    });
  });
}

// Simulates passing back a callback to Camera
Future<void> _makeCallback(dynamic arguments) {
  return defaultBinaryMessenger.handlePlatformMessage(
    Camera.channel.name,
    Camera.channel.codec.encodeMethodCall(
      MethodCall('handleCallback', arguments),
    ),
    (ByteData reply) {},
  );
}

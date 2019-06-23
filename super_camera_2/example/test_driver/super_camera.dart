// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_camera/super_camera.dart';

void main() {
  final Completer<String> completer = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => completer.future);
  tearDownAll(() => completer.complete(null));

  group('super_camera', () {
    group(
      'Support Android Camera',
      () {
        group('$SupportAndroidCamera', () {
          test('getNumberOfCameras', () {
            expectLater(
              SupportAndroidCamera.getNumberOfCameras(),
              completion(greaterThan(0)),
            );
          });

          test('getCameraInfo', () async {
            final CameraInfo info = await SupportAndroidCamera.getCameraInfo(0);

            expect(info.id, 0);
            expect(info.facing, Facing.back);
            expect(info.direction, LensDirection.back);
            expect(info.orientation, anyOf(0, 90, 180, 270));
          });

          test('open', () {
            final SupportAndroidCamera camera = SupportAndroidCamera.open(0);
            camera.release();
          });

          test('startPreview', () async {
            final SupportAndroidCamera camera = SupportAndroidCamera.open(0);
            expectLater(camera.startPreview(), completes);

            camera.release();
          });

          test('stopPreview', () async {
            final SupportAndroidCamera camera = SupportAndroidCamera.open(0);
            expect(camera.stopPreview(), completes);

            camera.release();
          });

          test('platformTexture', () async {
            final SupportAndroidCamera camera = SupportAndroidCamera.open(0);

            final PlatformTexture texture =
                await Camera.createPlatformTexture();
            expect(texture.textureId, isNotNull);

            camera.previewTexture = texture;
            texture.release();
          });
        });
      },
      skip: defaultTargetPlatform != TargetPlatform.android,
    );

    group(
      'Android Camera',
      () {
        final CameraManager manager = CameraManager.instance;

        group('$CameraManager', () {
          test('getCameraIdList', () async {
            final List<String> idList = await manager.getCameraIdList();

            expect(idList, isNotEmpty);
            expect(idList, everyElement(isNotNull));
          });

          test('getCameraCharacteristics', () async {
            final List<String> idList = await manager.getCameraIdList();

            final CameraCharacteristics chars =
                await manager.getCameraCharacteristics(idList[0]);

            expect(chars.id, idList[0]);
            expect(chars.direction, isNotNull);
            expect(chars.lensFacing, isNotNull);
            expect(chars.sensorOrientation, anyOf(0, 90, 180, 270));
          });

          test('openCamera', () async {
            final List<String> idList = await manager.getCameraIdList();

            final Completer<CameraDevice> completer = Completer<CameraDevice>();

            manager.openCamera(
              idList[0],
              (CameraDeviceState state, CameraDevice device) {
                completer.complete(device);
              },
            );

            final CameraDevice device = await completer.future;

            expect(device, isNotNull);
            expect(device.id, idList[0]);

            device.close();
          });
        });

        group('$CameraDevice', () {
          CameraDevice device;

          setUpAll(() async {
            final List<String> cameraIds = await manager.getCameraIdList();

            final Completer<CameraDevice> deviceCompleter =
                Completer<CameraDevice>();

            manager.openCamera(
              cameraIds[0],
              (CameraDeviceState state, CameraDevice device) {
                deviceCompleter.complete(device);
              },
            );

            device = await deviceCompleter.future;
          });

          tearDownAll(() {
            device.close();
          });

          test('createCaptureSession', () async {
            final PlatformTexture platformTexture =
                await Camera.createPlatformTexture();
            final SurfaceTexture surfaceTexture = SurfaceTexture();
            final PreviewTexture previewTexture = PreviewTexture(
              platformTexture: platformTexture,
              surfaceTexture: surfaceTexture,
            );

            final Completer<CameraCaptureSession> sessionCompleter =
                Completer<CameraCaptureSession>();

            device.createCaptureSession(
              <Surface>[previewTexture],
              (CameraCaptureSessionState state, CameraCaptureSession session) {
                sessionCompleter.complete(session);
              },
            );

            final CameraCaptureSession session = await sessionCompleter.future;

            expect(session, isNotNull);

            session.close();
            platformTexture.release();
          });
        });

        group('$CameraCaptureSession', () {
          CameraDevice device;
          CameraCaptureSession session;
          PlatformTexture platformTexture;
          List<Surface> surfaces;

          setUpAll(() async {
            final List<String> cameraIds = await manager.getCameraIdList();

            final Completer<CameraDevice> deviceCompleter =
                Completer<CameraDevice>();

            manager.openCamera(
              cameraIds[0],
              (CameraDeviceState state, CameraDevice device) {
                deviceCompleter.complete(device);
              },
            );

            device = await deviceCompleter.future;

            platformTexture = await Camera.createPlatformTexture();
            final SurfaceTexture surfaceTexture = SurfaceTexture();
            final PreviewTexture previewTexture = PreviewTexture(
              platformTexture: platformTexture,
              surfaceTexture: surfaceTexture,
            );

            surfaces = <Surface>[previewTexture];

            final Completer<CameraCaptureSession> sessionCompleter =
                Completer<CameraCaptureSession>();

            device.createCaptureSession(
              surfaces,
              (CameraCaptureSessionState state, CameraCaptureSession session) {
                sessionCompleter.complete(session);
              },
            );

            session = await sessionCompleter.future;
          });

          tearDownAll(() {
            device.close();
            session.close();
            platformTexture.release();
          });

          test('setRepeatingRequest', () async {
            CaptureRequest request = device.createCaptureRequest(
              Template.preview,
            );

            request = request.copyWith(targets: surfaces);
            await session.setRepeatingRequest(request: request);
          });
        });
      },
      skip: defaultTargetPlatform != TargetPlatform.android,
    );

    group('$Camera', () {
      test('availableCameras', () async {
        final List<CameraDescription> descriptions =
            await Camera.availableCameras();
        expect(descriptions, isNotEmpty);
      });

      test('createPlatformTexture', () async {
        final PlatformTexture texture = await Camera.createPlatformTexture();
        expect(texture.textureId, isNotNull);
      });
    });

    group('$CameraController', () {
      test('works', () async {
        final List<CameraDescription> descriptions =
            await Camera.availableCameras();

        final CameraController controller = CameraController(
          description: descriptions[0],
        );

        await expectLater(controller.api, isNotNull);
        await expectLater(
          controller.configurator.addPreviewTexture(),
          completes,
        );
        await expectLater(controller.start(), completes);
        await expectLater(controller.stop(), completes);
        await expectLater(controller.dispose(), completes);
      });
    });
  });
}

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:super_camera/super_camera.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  CameraController _controller;
  LensDirection _lensDirection = LensDirection.front;
  Widget _cameraWidget;
  bool _isToggling = false;

  @override
  void initState() {
    super.initState();
    _openCamera();
  }

  Future<void> _openCamera() async {
    Completer<void> completer = Completer<void>();

    final bool hasCameraAccess = await _getCameraPermission();

    if (!hasCameraAccess) {
      print('No camera access!');
      completer.isCompleted;
      return completer.future;
    }

    final List<CameraDevice> cameras = await Camera.availableCameras();

    final CameraDevice device = cameras.firstWhere(
      (CameraDevice device) => device.lensDirection == _lensDirection,
    );

    _controller = CameraController(device);

    final bool shouldMirror = device.lensDirection == LensDirection.front;

    _controller.open(
      onSuccess: () {
        print("Camera Opened!");

        _controller.putRepeatingCaptureRequest(
          RepeatingCaptureSettings(
            shouldMirror: shouldMirror,
            delegateSettings: TextureSettings(
              onTextureReady: (Texture texture) {
                print("Got texture!");

                int orientation = device.orientation;
                if (defaultTargetPlatform == TargetPlatform.iOS && shouldMirror) {
                  orientation = orientation + 180 % 360;
                }

                setState(() {
                  _cameraWidget = _buildCameraWidget(
                    orientation,
                    texture,
                  );
                });
                completer.complete();
              },
              onFailure: (CameraException exception) {
                print(exception);
                completer.complete();
              },
            ),
          ),
        );
      },
      onFailure: (CameraException exception) {
        print(exception);
        completer.complete();
      },
    );

    return completer.future;
  }

  Future<bool> _getCameraPermission() async {
    final PermissionStatus permission =
        await PermissionHandler().checkPermissionStatus(
      PermissionGroup.camera,
    );

    if (permission == PermissionStatus.granted) {
      return true;
    }

    final Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.camera]);

    return permissions[PermissionGroup.camera] == PermissionStatus.granted;
  }

  // Switches camera if another exists.
  Future<void> _toggleCamera() async {
    setState(() {
      _lensDirection = _lensDirection == LensDirection.back
          ? LensDirection.front
          : LensDirection.back;
    });

    await _controller.stopRepeatingCaptureRequest();
    await _controller.close();
    await _openCamera();
    _isToggling = false;
  }

  Widget _buildCameraWidget(int degrees, Texture texture) {
    return Transform.rotate(angle: degrees * pi / 180, child: texture);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: _cameraWidget ?? Text('Running Super Camera'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_isToggling) return;
            _isToggling = true;
            _toggleCamera();
          },
          child: _lensDirection == LensDirection.back
              ? const Icon(Icons.camera_front)
              : const Icon(Icons.camera_rear),
        ),
      ),
    );
  }
}

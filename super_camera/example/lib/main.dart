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
  Texture _texture;

  @override
  void initState() {
    super.initState();
    _openCamera();
  }

  void _openCamera() async {
    final bool hasCameraAccess = await _getCameraPermission();

    if (!hasCameraAccess) {
      print('No camera access!');
      return;
    }

    final List<CameraDevice> cameras = await Camera.availableCameras();

    final CameraDevice device = cameras.firstWhere(
      (CameraDevice device) => device.lensDirection == _lensDirection,
    );

    _controller = CameraController(device);

    _controller.open(
      onSuccess: () {
        print("Camera Opened!");

        _controller.putRepeatingCaptureRequest(
          RepeatingCaptureSettings(
            delegateSettings: TextureSettings(
              onTextureReady: (Texture texture) {
                print("Got texture!");

                setState(() {
                  _texture = texture;
                });
              },
              onFailure: (CameraException exception) {
                print(exception);
              },
            ),
          ),
        );
      },
      onFailure: (CameraException exception) {
        print(exception);
      },
    );
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
  void _toggleCamera() async {
    setState(() {
      _lensDirection = _lensDirection == LensDirection.back
          ? LensDirection.front
          : LensDirection.back;
    });

    await _controller.close();
    _openCamera();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: _texture == null ? Text('Running Super Camera') : _texture,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
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

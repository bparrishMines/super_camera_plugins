import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:super_camera/super_camera.dart';

DeviceOrientation appDeviceOrientation;

void main() {
  appDeviceOrientation = defaultTargetPlatform == TargetPlatform.iOS
      ? DeviceOrientation.landscapeRight
      : DeviceOrientation.landscapeLeft;

  SystemChrome.setEnabledSystemUIOverlays([]);
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    appDeviceOrientation,
  ]);

  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  CameraController _controller;
  LensDirection _lensDirection = LensDirection.back;
  Widget _cameraWidget;
  bool _isToggling = false;
  final double desiredAspectRatio =
      defaultTargetPlatform == TargetPlatform.iOS ? 16 / 9 : 4 / 3;

  @override
  void initState() {
    super.initState();
    _toggleCamera();
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

    final List<Size> sortedSizes = List.from(device.supportedVideoSizes);
    sortedSizes.sort((Size one, Size two) {
      final double areaOne = one.width * one.height;
      final double areaTwo = two.width * two.height;

      if (areaOne == areaTwo) return 0;
      return areaOne > areaTwo ? -1 : 1;
    });

    Size resolution = sortedSizes[0];
    double closestAspectRatio =
        (resolution.width / resolution.height) - desiredAspectRatio;
    for (int i = 1; i < sortedSizes.length; i++) {
      final double difference =
          (sortedSizes[i].width / sortedSizes[i].height) - desiredAspectRatio;
      if (closestAspectRatio.abs() > difference.abs()) {
        resolution = sortedSizes[i];
        closestAspectRatio = difference.abs();
      }
    }

    _controller = CameraController(device);

    VideoOrientation videoOrientation;
    switch (appDeviceOrientation) {
      case DeviceOrientation.landscapeLeft:
        videoOrientation = VideoOrientation.landscapeLeft;
        break;
      default:
        videoOrientation = VideoOrientation.landscapeRight;
    }

    final double aspectRatio = resolution.width / resolution.height;

    _controller.open(
      onSuccess: () {
        print("Camera Opened!");

        _controller.setVideoSettings(
          VideoSettings(
            shouldMirror: device.lensDirection == LensDirection.front,
            resolution: resolution,
            orientation: videoOrientation,
            delegateSettings: TextureSettings(
              onTextureReady: (Texture texture) {
                print("Got texture!");

                setState(() {
                  _cameraWidget = _buildCameraWidget(
                    texture,
                    aspectRatio,
                  );
                });

                _controller.startRunning();
                completer.complete();
              },
              onFailure: onFailure(completer),
            ),
          ),
        );
      },
      onFailure: onFailure(completer),
    );

    return completer.future;
  }

  Function(CameraException) onFailure(Completer completer) {
    return (CameraException exception) {
      print(exception);
      completer.complete();
    };
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

    await Camera.releaseAllResources();
    await _openCamera();
    _isToggling = false;
  }

  Widget _buildCameraWidget(Texture texture, double aspectRatio) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: texture,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          _cameraWidget ?? Text('Running Super Camera'),
          Expanded(
            child: Container(
              constraints: BoxConstraints.expand(),
              padding: EdgeInsets.all(10),
              child: Center(
                child: InkResponse(
                  onTap: () {
                    _controller.takePhoto(
                      PhotoSettings(
                        delegateSettings: DataSettings(
                          onImageDataAvailable: (_) => print('Picture Taken!'),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey, width: 2)),
                    child: new Icon(
                      Icons.camera,
                      color: Colors.grey,
                      size: 60,
                    ),
                  ),
                ),
              ),
              decoration: BoxDecoration(color: Colors.black),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: () {
          if (_isToggling) return;
          _isToggling = true;
          _toggleCamera();
        },
        child: const Icon(Icons.switch_camera),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    Camera.releaseAllResources();
  }
}

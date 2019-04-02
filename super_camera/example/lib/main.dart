import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:super_camera/super_camera.dart';

DeviceOrientation appDeviceOrientation;

void main() {
  SystemChrome.setEnabledSystemUIOverlays([]);
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const double _desiredAspectRatio = 16 / 9;

  CameraController _controller;
  LensDirection _lensDirection = LensDirection.back;
  Widget _cameraWidget;
  bool _isToggling = false;

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
        (resolution.width / resolution.height) - _desiredAspectRatio;
    for (int i = 1; i < sortedSizes.length; i++) {
      final double difference =
          (sortedSizes[i].width / sortedSizes[i].height) - _desiredAspectRatio;
      if (closestAspectRatio.abs() > difference.abs()) {
        resolution = sortedSizes[i];
        closestAspectRatio = difference.abs();
      }
    }

    _controller = CameraController(device);

    _controller.open(
      onSuccess: () {
        print("Camera Opened!");

        _controller.setVideoSettings(
          VideoSettings(
            shouldMirror: device.lensDirection == LensDirection.front,
            resolution: resolution,
            orientation: VideoOrientation.portraitUp,
            delegateSettings: TextureSettings(
              onTextureReady: (Texture texture) {
                print("Got texture!");

                setState(() {
                  _cameraWidget = _buildCameraWidget(
                    texture,
                    resolution.height / resolution.width,
                  );
                });

                _controller.startRunning();
                completer.complete();
              },
              onFailure: _onFailure(completer),
            ),
          ),
        );
      },
      onFailure: _onFailure(completer),
    );

    return completer.future;
  }

  Function(CameraException) _onFailure(Completer completer) {
    return (CameraException exception) {
      print(exception);
      completer?.complete();
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
    _lensDirection = _lensDirection == LensDirection.back
        ? LensDirection.front
        : LensDirection.back;

    setState(() {
      _cameraWidget = null;
    });

    await Camera.releaseAllResources();
    await _openCamera();
  }

  void _takePicture() {
    _controller.takePhoto(
      PhotoSettings(
        delegateSettings: DataSettings(
          onImageDataAvailable: (_) => print('Picture Taken!'),
          onFailure: _onFailure(null),
        ),
      ),
    );
  }

  Widget _buildCameraWidget(Texture texture, double aspectRatio) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: texture,
    );
  }

  Widget _buildPictureButton() {
    return InkResponse(
      onTap: _takePicture,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Center(
                child: _cameraWidget ?? Container(),
              ),
              decoration: BoxDecoration(
                color: Colors.black,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 30, left: 10, right: 10, top: 15),
            child: Stack(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 10),
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(
                      Icons.switch_camera,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () {
                      if (!_isToggling) {
                        _isToggling = true;
                        _toggleCamera().then((_) => _isToggling = false);
                      }
                    },
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: _buildPictureButton(),
                )
              ],
            ),
            decoration: BoxDecoration(color: Colors.black),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    Camera.releaseAllResources();
  }
}

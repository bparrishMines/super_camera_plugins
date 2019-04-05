import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:super_camera/super_camera.dart';
import 'package:sensors/sensors.dart';

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
  CameraController _controller;
  LensDirection _lensDirection = LensDirection.back;
  Widget _cameraWidget;
  bool _isToggling = false;
  double _deviceRotation = 0;
  StreamSubscription<AccelerometerEvent> _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    _setupAccelerometer();
    _toggleCamera();
  }

  void _setupAccelerometer() {
    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      final double maxAcceleration = 9.81 * .75;

      double newDeviceRotation;
      if (event.x > maxAcceleration) {
        newDeviceRotation = pi / 2.0;
      } else if (event.y > maxAcceleration) {
        newDeviceRotation = 0;
      } else if (event.x < -maxAcceleration) {
        newDeviceRotation = -pi / 2.0;
      } else if (event.y < -maxAcceleration) {
        newDeviceRotation = pi;
      } else {
        return;
      }

      if (_deviceRotation != newDeviceRotation) {
        setState(() {
          _deviceRotation = newDeviceRotation;
        });
      }
    });
  }

  Future<void> _openCamera() async {
    Completer<void> completer = Completer<void>();

    final bool hasCameraAccess = await _getCameraPermission();

    if (!hasCameraAccess) {
      print('No camera access!');
      completer.complete();
      return completer.future;
    }

    final CameraDevice device = await CameraUtils.cameraDeviceForDirection(
      _lensDirection,
    );
    _controller = CameraController(device);

    final VideoFormat bestVideoFormat =
        CameraUtils.bestVideoFormatForAspectRatio(
      videoFormats: device.videoFormats,
      aspectRatio: 16 / 9,
    );

    _controller.open(
      onSuccess: () {
        print("Camera Opened!");

        _controller.setVideoSettings(
          VideoSettings(
            shouldMirror: device.lensDirection == LensDirection.front,
            videoFormat: bestVideoFormat,
            orientation: VideoOrientation.portraitUp,
            delegateSettings: TextureSettings(
              onTextureReady: (Texture texture) {
                print("Got texture!");

                setState(() {
                  _cameraWidget = _buildCameraWidget(
                    texture,
                    bestVideoFormat.dimensions.height /
                        bestVideoFormat.dimensions.width,
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
                  child: Transform.rotate(
                    angle: _deviceRotation,
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
    _accelerometerSubscription.cancel();
    Camera.releaseAllResources();
  }
}

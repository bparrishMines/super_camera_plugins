import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
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
    final bool hasCameraAccess = await _getCameraPermission();

    if (!hasCameraAccess) {
      print('No camera access!');
      return;
    }

    final CameraDevice device = await CameraUtils.cameraDeviceForDirection(
      _lensDirection,
    );

    final List<VideoFormat> videoFormats = device.videoFormats
        .where(
          (VideoFormat format) => format.pixelFormat == PixelFormat.bgra8888,
        )
        .toList();

    final VideoFormat bestVideoFormat =
        CameraUtils.bestVideoFormatForAspectRatio(
      videoFormats: defaultTargetPlatform == TargetPlatform.iOS
          ? videoFormats
          : device.videoFormats,
      aspectRatio: 16 / 9,
    );

    _controller = CameraController(device);
    try {
      await _controller.open();

      await _controller.setVideoSettings(
        VideoSettings(
          shouldMirror: device.lensDirection == LensDirection.front,
          videoFormat: bestVideoFormat,
          orientation: VideoOrientation.portraitUp,
          delegate: TextureDelegate(
            onTextureReady: (Texture texture) {
              print("Got texture!");

              setState(() {
                _cameraWidget = _buildCameraWidget(
                  texture,
                  bestVideoFormat.dimensions.height /
                      bestVideoFormat.dimensions.width,
                );
              });
            },
          ),
        ),
      );

      await _controller.setPhotoSettings(
        PhotoSettings(
          delegate: DataDelegate(
            onImageDataAvailable: (bytes) => print(bytes.length),
          ),
        ),
      );

      await _controller.startRunning();
    } on CameraException catch (exception) {
      print(exception);
      await _controller.close();
    }
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

  Widget _buildCameraWidget(Texture texture, double aspectRatio) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: texture,
    );
  }

  Widget _buildPictureButton() {
    return InkResponse(
      onTap: () {
        _controller.takePhoto().catchError((_) => print(_));
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
    _accelerometerSubscription.cancel();
    Camera.releaseAllResources();
    super.dispose();
  }
}

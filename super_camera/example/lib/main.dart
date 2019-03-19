import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:super_camera/super_camera.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    testCameraPlugin();
  }

  Future<void> testCameraPlugin() async {
    final bool hasCameraAccess = await getCameraPermission();
    final List<CameraDevice> cameras = await Camera.availableCameras();

    final CameraDevice device = cameras[0];
    print(device);

    final CameraController controller = CameraController(device);

    controller.open(
      onSuccess: () {
        print('Camera Opened!');
      },
      onFailure: (CameraException exception) {
        print(exception);
      },
    );

    controller.open(
      onSuccess: () {
        print('Camera Opened!');
      },
      onFailure: (CameraException exception) {
        print(exception);
      },
    );
  }

  Future<bool> getCameraPermission() async {
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running Super Camera'),
        ),
      ),
    );
  }
}

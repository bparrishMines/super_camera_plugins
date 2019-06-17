part of super_camera;

class CameraPreview extends StatefulWidget {
  CameraPreview(this.controller);

  final CameraController controller;

  @override
  State<StatefulWidget> createState() => _CameraPreviewState();
}

class _CameraPreviewState extends State<CameraPreview> {
  RotatedBox _buildPreviewWidget(int textureId) {
    final CameraController controller = widget.controller;
    int rotation = 0;
    if (controller.api == CameraApi.supportAndroid) {
      rotation = (controller.description as CameraInfo).orientation;
      if (widget.controller.description.direction == LensDirection.front) {
        rotation = (rotation + 180) % 360;
      }
    }

    return RotatedBox(
      quarterTurns: (rotation / 90).floor(),
      child: Texture(textureId: textureId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CameraConfigurator config = widget.controller.config;

    if (config.previewTextureId != null) {
      return _buildPreviewWidget(config.previewTextureId);
    }

    widget.controller.stop();
    return FutureBuilder<void>(
      future: config.createPreviewTexture(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Container();
          case ConnectionState.done:
            widget.controller.start();
            return _buildPreviewWidget(config.previewTextureId);
        }
        return null; // unreachable
      },
    );
  }
}

part of super_camera;

class CaptureSession with _NativeMethodCallHandler, _CameraMappable {
  CaptureSession();

  final List<CaptureOutput> _outputs = <CaptureOutput>[];
  final List<CaptureInput> _inputs = <CaptureInput>[];

  List<CaptureOutput> get outputs => List<CaptureOutput>.unmodifiable(_outputs);
  List<CaptureInput> get inputs => List<CaptureInput>.unmodifiable(_inputs);

  Future<void> addOutput(CaptureOutput output) {
    assert(output != null);
    assert(!_outputs.contains(output));

    _outputs.add(output);
    try {
      return running
        ..then((bool isRunning) {
          if (isRunning) {
            Camera.channel.invokeMethod<void>(
              '$CaptureSession#addOutput',
              <String, dynamic>{'handle': _handle, 'output': output.asMap()},
            );
          }
        });
    } on PlatformException {
      _outputs.remove(output);
      rethrow;
    }
  }

  Future<void> removeOutput(CaptureOutput output) {
    if (!_outputs.remove(output)) return Future<void>.value();

    return running
      ..then((bool isRunning) {
        if (isRunning) {
          Camera.channel.invokeMethod<void>(
            '$CaptureSession#removeOutput',
            <String, dynamic>{'handle': _handle, 'output': output.asMap()},
          );
        }
      });
  }

  Future<void> addInput(CaptureInput input) {
    assert(input != null);
    assert(!_inputs.contains(input));

    _inputs.add(input);

    try {
      return running
        ..then((bool isRunning) {
          if (isRunning) {
            Camera.channel.invokeMethod<void>(
              '$CaptureSession#addInput',
              <String, dynamic>{'handle': _handle, 'input': input.asMap()},
            );
          }
        });
    } on PlatformException {
      _inputs.remove(input);
      rethrow;
    }
  }

  Future<void> removeInput(CaptureInput input) {
    if (!_inputs.remove(input)) return Future<void>.value();

    return running
      ..then((bool isRunning) {
        if (isRunning) {
          Camera.channel.invokeMethod<void>(
            '$CaptureSession#removeInput',
            <String, dynamic>{'handle': _handle, 'input': input.asMap()},
          );
        }
      });
  }

  Future<void> startRunning() {
    assert(inputs.length > 0);
    assert(outputs.length > 0);

    return Camera.channel.invokeMethod<void>(
      '$CaptureSession#startRunning',
      <String, dynamic>{'handle': _handle, ...asMap()},
    );
  }

  Future<void> stopRunning() {
    return Camera.channel.invokeMethod<void>(
      '$CaptureSession#stopRunning',
      <String, dynamic>{'handle': _handle},
    );
  }

  Future<bool> get running {
    return Camera.channel.invokeMethod<bool>(
      '$CaptureSession#running',
      <String, dynamic>{'handle': _handle},
    );
  }

  @override
  Map<String, dynamic> asMap() {
    return <String, dynamic>{
      'inputs': inputs
          .map<Map<String, dynamic>>((CaptureInput input) => input.asMap())
          .toList(),
      'outputs': outputs
          .map<Map<String, dynamic>>((CaptureOutput output) => output.asMap())
          .toList(),
    };
  }
}

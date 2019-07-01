part of super_camera;

class CaptureSession with _NativeMethodCallHandler, _CameraMappable {
  bool _running = false;

  final List<CaptureOutput> _outputs = <CaptureOutput>[];
  final List<CaptureInput> _inputs = <CaptureInput>[];

  List<CaptureOutput> get outputs => List<CaptureOutput>.unmodifiable(_outputs);
  List<CaptureInput> get inputs => List<CaptureInput>.unmodifiable(_inputs);

  Future<void> addOutput(CaptureOutput output) {
    assert(output != null);
    assert(!_outputs.contains(output));

    _outputs.add(output);

    if (running) {
      Camera.channel.invokeMethod<void>(
        '$CaptureSession#addOutput',
        <String, dynamic>{'handle': _handle, 'output': output.asMap()},
      );
    }

    return Future<void>.value();
  }

  Future<void> removeOutput(CaptureOutput output) {
    if (!_outputs.remove(output)) return Future<void>.value();

    if (running) {
      return Camera.channel.invokeMethod<void>(
        '$CaptureSession#removeOutput',
        <String, dynamic>{'handle': _handle, 'output': output.asMap()},
      );
    }

    return Future<void>.value();
  }

  Future<void> addInput(CaptureInput input) {
    assert(input != null);
    assert(!_inputs.contains(input));

    _inputs.add(input);

    if (running) {
      return Camera.channel.invokeMethod<void>(
        '$CaptureSession#addInput',
        <String, dynamic>{'handle': _handle, 'input': input.asMap()},
      );
    }

    return Future<void>.value();
  }

  Future<void> removeInput(CaptureInput input) {
    if (!_inputs.remove(input)) return Future<void>.value();

    if (running) {
      return Camera.channel.invokeMethod<void>(
        '$CaptureSession#removeInput',
        <String, dynamic>{'handle': _handle, 'input': input.asMap()},
      );
    }

    return Future<void>.value();
  }

  Future<void> startRunning() {
    _running = true;
    try {
      return Camera.channel.invokeMethod<void>(
        '$CaptureSession#startRunning',
        <String, dynamic>{'sessionHandle': _handle, ...asMap()},
      );
    } on PlatformException {
      _running = false;
      rethrow;
    }
  }

  Future<void> stopRunning() {
    _running = false;
    return Camera.channel.invokeMethod<void>(
      '$CaptureSession#stopRunning',
      <String, dynamic>{'handle': _handle},
    );
  }

  bool get running => _running;

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

import 'dart:async';
import 'dart:math';

import 'tts_service.dart';

class DetectedObject {
  final String label;
  final String direction;
  final int meters;

  const DetectedObject(
    this.label,
    this.direction,
    this.meters,
  );

  String get speech {

    if (direction == 'front') {
      return 'Person in front $meters meters';
    }

    return 'Person to the $direction $meters meters';
  }
}

class ScanService {

  ScanService._();

  static final ScanService instance =
      ScanService._();

  final Random _random = Random();

  bool _scanning = false;

  void Function(List<DetectedObject>)?
      onDetection;

  bool get isScanning => _scanning;

  // =========================
  // START
  // =========================

  void start() {

    if (_scanning) return;

    _scanning = true;

    _startLoop();
  }

  // =========================
  // LOOP
  // =========================

  Future<void> _startLoop() async {

    while (_scanning) {

      await _fakeDetection();

      await Future.delayed(
        const Duration(seconds: 2),
      );
    }
  }

  // =========================
  // STOP
  // =========================

  void stop() {

    _scanning = false;

    onDetection?.call([]);
  }

  // =========================
  // PERSON DETECTION MOCK
  // =========================

  Future<void> _fakeDetection() async {

    if (!_scanning) return;

    final directions = [
      'left',
      'front',
      'right',
    ];

    final direction =
        directions[
            _random.nextInt(
              directions.length,
            )];

    final distance =
        1 + _random.nextInt(4);

    final detection = DetectedObject(
      'person',
      direction,
      distance,
    );

    final detections = [detection];

    onDetection?.call(detections);

    await TtsService.instance.speak(
      detection.speech,
    );
  }
}
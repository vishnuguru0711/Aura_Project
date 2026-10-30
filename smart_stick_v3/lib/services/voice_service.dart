import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'tts_service.dart';

typedef NavigateCallback = void Function(String destination);
typedef SosCallback      = void Function();
typedef TabCallback      = void Function(int index);
typedef ScanCallback     = void Function();

class VoiceService {

  VoiceService._();

  static final VoiceService instance =
      VoiceService._();

  final SpeechToText _stt =
      SpeechToText();

  bool _available = false;

  bool _listening = false;

  // FIX 3:
  // IGNORE COMMANDS WHILE SPEAKING
  bool _processingCommand = false;

  NavigateCallback? onNavigate;

  SosCallback? onSos;

  TabCallback? onTabSwitch;

  ScanCallback? onScan;

  static const List<String>
      _sosKeywords = [
    'help',
    'emergency',
    'sos',
    'danger',
    'save me',
    'call help',
  ];

  // =========================
  // START
  // =========================

  Future<void> startListening(
      BuildContext context) async {

    _available =
        await _stt.initialize(
      onError: (e) =>
          debugPrint(
        'STT error: $e',
      ),
    );

    if (_available) {
      _listenLoop();
    }
  }

  // =========================
  // STOP
  // =========================

  void stopListening() {

    _listening = false;

    _processingCommand = false;

    _stt.stop();
  }

  // =========================
  // CONTINUOUS LISTEN LOOP
  // =========================

  void _listenLoop() async {

    _listening = true;

    while (_listening) {

      // DO NOT LISTEN
      // WHILE PROCESSING COMMAND
      if (!_stt.isListening &&
          !_processingCommand) {

        try {

          await _stt.listen(

            onResult: (r) async {

              if (!r.finalResult) {
                return;
              }

              final cmd =
                  r.recognizedWords
                      .toLowerCase()
                      .trim();

              await _handleCommand(
                cmd,
              );
            },

            listenFor:
                const Duration(
              seconds: 10,
            ),

            pauseFor:
                const Duration(
              seconds: 3,
            ),

            cancelOnError: false,

            partialResults: false,
          );

        } catch (_) {}
      }

      await Future.delayed(
        const Duration(
          milliseconds: 400,
        ),
      );
    }
  }

  // =========================
  // COMMAND HANDLER
  // =========================

  Future<void> _handleCommand(
      String cmd) async {

    if (cmd.isEmpty) return;

    // FIX 3:
    // IGNORE DUPLICATE COMMANDS
    if (_processingCommand) {
      return;
    }

    _processingCommand = true;

    debugPrint(
      'Voice command: "$cmd"',
    );

    // FIX 1:
    // STOP MIC BEFORE SPEAKING
    await _stt.stop();

    // =====================
    // SOS
    // =====================

    if (_sosKeywords.any(
      (k) => cmd.contains(k),
    )) {

      await TtsService.instance
          .speak(
        'S O S activated. Sending emergency alert to guardian.',
      );

      onSos?.call();
    }

    // =====================
    // NAVIGATE
    // =====================

    else if (
        cmd.contains('navigate') ||
        cmd.contains('go to') ||
        cmd.contains('take me to')) {

      String dest = cmd

          .replaceAll(
            'navigate to',
            '',
          )

          .replaceAll(
            'navigate',
            '',
          )

          .replaceAll(
            'go to',
            '',
          )

          .replaceAll(
            'take me to',
            '',
          )

          .trim();

      if (dest.isNotEmpty) {

        await TtsService.instance
            .speak(
          'Opening navigation to $dest',
        );

        onNavigate?.call(dest);

      } else {

        await TtsService.instance
            .speak(
          'Please say a destination. For example, navigate to hospital.',
        );

        onTabSwitch?.call(2);
      }
    }

    // =====================
    // SCAN
    // =====================

    else if (
        cmd.contains('scan') ||
        cmd.contains('detect') ||
        cmd.contains('object') ||
        cmd.contains('what is')) {

      await TtsService.instance
          .speak(
        'Scanning surroundings.',
      );

      onScan?.call();

      onTabSwitch?.call(1);
    }

    // =====================
    // HOME
    // =====================

    else if (cmd.contains('home')) {

      await TtsService.instance
          .speak(
        'Opening home.',
      );

      onTabSwitch?.call(0);
    }

    // =====================
    // UNKNOWN
    // =====================

    else {

      await TtsService.instance
          .speak(
        'Say navigate to a place, scan, or help.',
      );
    }

    // FIX 2:
    // COOLDOWN AFTER TTS
    await Future.delayed(
      const Duration(
        seconds: 3,
      ),
    );

    // ALLOW LISTENING AGAIN
    _processingCommand = false;
  }

  bool get isListening =>
      _stt.isListening;
}
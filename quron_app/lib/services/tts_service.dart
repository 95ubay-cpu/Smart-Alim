import 'package:flutter/services.dart';

/// Wraps the native Android TextToSpeech engine exposed via a MethodChannel.
/// Mirrors the web page's `speak(text)` behaviour (reads an ayah aloud).
class TtsService {
  TtsService._();
  static const MethodChannel _channel =
      MethodChannel('com.smartalim.quron_app/tts');

  static Future<void> speak(String text) async {
    try {
      await _channel.invokeMethod('speak', {'text': text});
    } catch (_) {
      // TTS unavailable; ignore silently.
    }
  }

  static Future<void> stop() async {
    try {
      await _channel.invokeMethod('stop');
    } catch (_) {}
  }
}

import 'dart:async';

import 'package:flutter/services.dart';

enum CONTENT_TYPE { MUSIC, MOVIE, GAME, VOICE }

class Equalizer {
  static const MethodChannel _channel = const MethodChannel('equalizer');

  /// Open's the device equalizer.
  ///
  /// - [audioSessionId] enable audio effects for the current session.
  /// - [contentType] optional parameter. Defaults to [CONTENT_TYPE.MUSIC]
  ///
  /// [android]:
  /// https://developer.android.com/reference/android/media/MediaPlayer#getAudioSessionId()
  static Future<void> openEqualizer(int audioSessionId,
      [CONTENT_TYPE contentType]) async {
    await _channel.invokeMethod(
      'openEqualizer',
      {
        'audioSessionId': audioSessionId,
        'contentType': contentType == null ? 0 : contentType.index,
      },
    );
  }

  /// Set [audioSessionId] for equalizer.
  ///
  /// [android]:
  /// https://developer.android.com/reference/android/media/MediaPlayer#getAudioSessionId()
  static Future<void> setAudioSessionId(int audioSessionId) async {
    await _channel.invokeMethod('setAudioSessionId', audioSessionId);
  }

  /// Remove current [audioSessionId] for equalizer.
  static Future<void> removeAudioSessionId(int audioSessionId) async {
    await _channel.invokeMethod('removeAudioSessionId', audioSessionId);
  }

  /// Not implemented.
  static Future<void> customEqualizer() async {
    //TODO: Add support for custom equalizer here.
    return;
  }
}

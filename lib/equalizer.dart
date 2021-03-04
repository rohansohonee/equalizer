import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum CONTENT_TYPE { MUSIC, MOVIE, GAME, VOICE }

class Equalizer {
  static AnimationController _animationController;
  static const MethodChannel _channel = const MethodChannel('equalizer');

  /// Open's the device equalizer.
  ///
  /// - [audioSessionId] enable audio effects for the current session.
  /// - [contentType] optional parameter. Defaults to [CONTENT_TYPE.MUSIC]
  ///
  /// [android]:
  /// https://developer.android.com/reference/android/media/MediaPlayer#getAudioSessionId()
  static Future open(int audioSessionId,
      [CONTENT_TYPE contentType = CONTENT_TYPE.MUSIC]) async {
    return await _channel.invokeMethod(
      'open',
      {'audioSessionId': audioSessionId, 'contentType': contentType.index},
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

  /// Initialize a custom equalizer.
  ///
  /// [audioSessionId] enable audio effects for the current session.
  static Future<void> init(int audioSessionId) async {
    await _channel.invokeMethod('init', audioSessionId);
  }

  /// Release the custom equalizer resources.
  static Future<void> release() async {
    await _channel.invokeMethod('release');
  }

  /// Enable/disable a custom equalizer.
  static Future<void> setEnabled(bool enabled) async {
    await _channel.invokeMethod('enable', enabled);
  }

  /// Returns the band level range in a list of integers represented in [dB].
  /// The first element is
  /// the lower limit of the range, the second element the upper limit.
  static Future<List<int>> getBandLevelRange() async {
    return (await _channel.invokeMethod('getBandLevelRange')).cast<int>();
  }

  /// Returns the band level in [dB].
  static Future<int> getBandLevel(int bandId) async {
    return await _channel.invokeMethod('getBandLevel', bandId);
  }

  /// Set the band level for a custom equalizer.
  ///
  /// - [bandId] can be retrieved from [getCenterBandFreqs]
  /// - [level] can be retrieved from [getBandLevel]
  static Future<void> setBandLevel(int bandId, int level) async {
    // The level retrieved here is in dB. The native platform requires
    // the level in millibels.
    await _channel.invokeMethod(
      'setBandLevel',
      {'bandId': bandId, 'level': level * 100},
    );
  }

  /// Returns the center band frequencies in milliHertz.
  static Future<List<int>> getCenterBandFreqs() async {
    return (await _channel.invokeMethod('getCenterBandFreqs')).cast<int>();
  }

  /// Returns the preset names available on device.
  static Future<List<String>> getPresetNames() async {
    return (await _channel.invokeMethod('getPresetNames')).cast<String>();
  }

  /// Set the preset name.
  static Future<void> setPreset(String presetName) async {
    await _channel.invokeMethod('setPreset', presetName);
  }

  static Future<AnimationController> cutOffFrequency({
    @required int cutOffFreq,
    @required TickerProvider vsync,
    Duration duration = const Duration(seconds: 1),
  }) async {
    if (_animationController != null) {
      _animationController.dispose();
      _animationController = null;
    }

    _animationController = AnimationController(
      vsync: vsync,
      duration: duration,
    );

    var centerFreqs = await Equalizer.getCenterBandFreqs();
    var bandLevelRange = await Equalizer.getBandLevelRange();
    var min = bandLevelRange[0];

    List<IntTween> tweens = await Future.wait(centerFreqs.map((item) async {
      var index = centerFreqs.indexOf(item);
      var freq = (item ~/ 1000);

      var nextFreq =
          index + 1 < centerFreqs.length ? (centerFreqs[index + 1] ~/ 1000) : 0;

      var step = min.abs() / freq;

      var newValue = -((step * cutOffFreq).toInt()).toInt();
      newValue = newValue < min ? min.toInt() : newValue;

      if (freq > cutOffFreq && (freq >= cutOffFreq && nextFreq <= cutOffFreq)) {
        newValue = 0;
      }

      return IntTween(begin: await Equalizer.getBandLevel(index), end: newValue)
        ..animate(_animationController);
    }));

    _animationController.addListener(() {
      tweens.forEach((tween) {
        var index = tweens.indexOf(tween);
        Equalizer.setBandLevel(index, tween.evaluate(_animationController));
      });
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.dispose();
        _animationController = null;
      }
    });

    return _animationController..forward();
  }
}

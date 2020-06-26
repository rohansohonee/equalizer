# equalizer

A Flutter plugin to open the device equalizer.

Currently, supported on **Android** only. I encourage **iOS**
contributions from community members.

## Usage
To use this plugin, add `equalizer` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

### Example

``` dart
// Import package
import 'package:equalizer/equalizer.dart';

// Open equalizer
Equalizer.openEqualizer(audioSessionId);

// Set or remove audioSessionId.
Equalizer.setAudioSessionId(audioSessionId);
Equalizer.removeAudioSessionId(audioSessionId);
```
>You can retrieve `audioSessionId` on android from MediaPlayer. Info on how to do this can be found in
>`openEqualizer` docs.

## TODO

- Add iOS support.
- Add custom equalizer.

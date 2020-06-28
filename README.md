# equalizer

A Flutter plugin to open the device equalizer. You can also create a custom equalizer for Android.

Currently, supported on **Android** only. **Need help for iOS contributions.**

<img width="250px" alt="Example" src="https://user-images.githubusercontent.com/20875177/85949432-67615b80-b974-11ea-81e5-536caf232dc6.png">

## Android Setup
Edit your project's `AndroidManifest.xml` file to declare the permission to modify audio settings when creating a **custom equalizer**.
```xml
<manifest>
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    <application...>
    
    ...
    </application...>
</manifest>
```

## Example

```dart
// Import package
import 'package:equalizer/equalizer.dart';

// Open device equalizer
Equalizer.open(audioSessionId);

// Set or remove audioSessionId.
Equalizer.setAudioSessionId(audioSessionId);
Equalizer.removeAudioSessionId(audioSessionId);
```
> You can retrieve `audioSessionId` on android from MediaPlayer. Info on how to do this can be found in `openEqualizer` docs.

## Custom Equalizer Example

Initialize the equalizer. Recommended to perform inside initState
```dart
Equalizer.init(audioSessionId);
```

Enable the equalizer as follows.
```dart
Equalizer.setEnabled(true);
```

Now you can query the methods.
```dart
await Equalizer.getBandLevelRange(); // provides band level range in dB.

await Equalizer.getBandLevel(bandId);
Equalizer.setBandLevel(bandId,bandLevel);

await Equalizer.getCenterBandFreqs(); // provides the center freqs in milliHertz.

await Equalizer.getPresetNames(); // returns presets that are available on device
Equalizer.setPreset(presetName);
```

Finally, remember to release resources. Recommended to perform inside dispose
```dart
Equalizer.release();
```

## TODO

- Add iOS support.
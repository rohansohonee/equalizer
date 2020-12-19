package com.rohansohonee.equalizer;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.media.audiofx.AudioEffect;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * EqualizerPlugin
 */
public class EqualizerPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
	private MethodChannel methodChannel;
	private Context applicationContext;
	private Activity activity;

	@Override
	public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
		this.applicationContext = binding.getApplicationContext();
		methodChannel = new MethodChannel(binding.getBinaryMessenger(), "equalizer");
		methodChannel.setMethodCallHandler(this);
	}


	@Override
	public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
		switch (call.method) {
		case "open":
			int sessionId = (int)call.argument("audioSessionId");
			int content_type = (int)call.argument("contentType");
			displayDeviceEqualizer(sessionId, content_type, result);
			break;
		case "deviceHasEqualizer":
			result.success(deviceHasEqualizer((int)call.argument("audioSessionId")));
			break;
		case "setAudioSessionId":
			setAudioSessionId((int)call.arguments);
			break;
		case "removeAudioSessionId":
			removeAudioSessionId((int)call.arguments);
			break;
		case "init":
			CustomEQ.init((int)call.arguments);
			break;
		case "enable":
			CustomEQ.enable((boolean)call.arguments);
			break;
		case "release":
			CustomEQ.release();
			break;
		case "getBandLevelRange":
			result.success(CustomEQ.getBandLevelRange());
			break;
		case "getCenterBandFreqs":
			result.success(CustomEQ.getCenterBandFreqs());
			break;
		case "getPresetNames":
			result.success(CustomEQ.getPresetNames());
			break;
		case "getBandLevel":
			result.success(CustomEQ.getBandLevel((int)call.arguments));
			break;
		case "setBandLevel":
			int bandId = (int)call.argument("bandId");
			int level = (int)call.argument("level");
			CustomEQ.setBandLevel(bandId, level);
			break;
		case "setPreset":
			CustomEQ.setPreset((String)call.arguments);
			break;
		default:
			result.notImplemented();
			break;
		}
	}

	void displayDeviceEqualizer(int sessionId, int content_type, Result result) {
		Intent intent = new Intent(AudioEffect.ACTION_DISPLAY_AUDIO_EFFECT_CONTROL_PANEL);
		intent.putExtra(AudioEffect.EXTRA_PACKAGE_NAME, applicationContext.getPackageName());
		intent.putExtra(AudioEffect.EXTRA_AUDIO_SESSION, sessionId);
		intent.putExtra(AudioEffect.EXTRA_CONTENT_TYPE, content_type);
		if ((intent.resolveActivity(applicationContext.getPackageManager()) != null)) {
			activity.startActivityForResult(intent, 0);
		} else {
			result.error("EQ",
					"No equalizer found!",
					"This device may lack equalizer functionality."
			);
		}
	}

	boolean deviceHasEqualizer(int sessionId) {
		Intent intent = new Intent(AudioEffect.ACTION_DISPLAY_AUDIO_EFFECT_CONTROL_PANEL);
		intent.putExtra(AudioEffect.EXTRA_PACKAGE_NAME, applicationContext.getPackageName());
		intent.putExtra(AudioEffect.EXTRA_AUDIO_SESSION, sessionId);
		return intent.resolveActivity(applicationContext.getPackageManager()) != null;
	}

	void setAudioSessionId(int sessionId) {
		Intent i = new Intent(AudioEffect.ACTION_OPEN_AUDIO_EFFECT_CONTROL_SESSION);
		i.putExtra(AudioEffect.EXTRA_PACKAGE_NAME, applicationContext.getPackageName());
		i.putExtra(AudioEffect.EXTRA_AUDIO_SESSION, sessionId);
		applicationContext.sendBroadcast(i);
	}

	void removeAudioSessionId(int sessionId) {
		Intent i = new Intent(AudioEffect.ACTION_CLOSE_AUDIO_EFFECT_CONTROL_SESSION);
		i.putExtra(AudioEffect.EXTRA_PACKAGE_NAME, applicationContext.getPackageName());
		i.putExtra(AudioEffect.EXTRA_AUDIO_SESSION, sessionId);
		applicationContext.sendBroadcast(i);
	}


	@Override
	public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
		applicationContext = null;
		methodChannel.setMethodCallHandler(null);
		methodChannel = null;
	}


	@Override
	public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
		this.activity = binding.getActivity();
	}

	@Override
	public void onDetachedFromActivityForConfigChanges() {

	}

	@Override
	public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

	}

	@Override
	public void onDetachedFromActivity() {
		activity = null;
	}
}

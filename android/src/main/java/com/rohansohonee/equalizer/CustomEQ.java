package com.rohansohonee.equalizer;

import android.media.audiofx.Equalizer;

import java.util.ArrayList;

public class CustomEQ {
	private static Equalizer equalizer;

	public static void init(int sessionId) {
		equalizer = new Equalizer(0, sessionId);
	}

	public static void enable(boolean enable) {
		if (equalizer != null)
			equalizer.setEnabled(enable);
	}

	public static void release() {
		if (equalizer != null)
			equalizer.release();
	}

	public static ArrayList<Integer> getBandLevelRange() {
		short[] bandLevelRange = equalizer.getBandLevelRange();
		ArrayList<Integer> bandLevels = new ArrayList<>();
		bandLevels.add(bandLevelRange[0] / 100);
		bandLevels.add(bandLevelRange[1] / 100);
		return bandLevels;
	}

	public static int getBandLevel(int bandId) {
		return equalizer.getBandLevel((short)bandId) / 100;
	}

	public static void setBandLevel(int bandId, int level) {
		equalizer.setBandLevel((short)bandId, (short)level);
	}

	public static ArrayList<Integer> getCenterBandFreqs() {
		int n = equalizer.getNumberOfBands();
		ArrayList<Integer> bands = new ArrayList<>();
		for (int i = 0; i < n; i++) {
			bands.add(equalizer.getCenterFreq((short)i));
		}
		return bands;
	}

	public static ArrayList<String> getPresetNames() {
		short numberOfPresets = equalizer.getNumberOfPresets();
		ArrayList<String> presets = new ArrayList<>();
		for (int i = 0; i < numberOfPresets; i++) {
			presets.add(equalizer.getPresetName((short)i));
		}
		return presets;
	}

	public static void setPreset(String presetName) {
		equalizer.usePreset((short)getPresetNames().indexOf(presetName));
	}
}

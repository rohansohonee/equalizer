import 'dart:async';

import 'package:equalizer/equalizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool enableCustomEQ = false;

  @override
  void initState() {
    super.initState();
    Equalizer.init(0);
  }

  @override
  void dispose() {
    Equalizer.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Equalizer example'),
        ),
        body: ListView(
          children: [
            SizedBox(height: 10.0),
            Center(
              child: FlatButton.icon(
                icon: Icon(Icons.equalizer),
                label: Text('Open device equalizer'),
                color: Colors.blue,
                textColor: Colors.white,
                onPressed: () => Equalizer.open(0),
              ),
            ),
            SizedBox(height: 10.0),
            Container(
              color: Colors.grey.withOpacity(0.1),
              child: SwitchListTile(
                title: Text('Custom Equalizer'),
                value: enableCustomEQ,
                onChanged: (value) {
                  Equalizer.setEnabled(value);
                  setState(() {
                    enableCustomEQ = value;
                  });
                },
              ),
            ),
            FutureBuilder<List<int>>(
              future: Equalizer.getBandLevelRange(),
              builder: (context, snapshot) {
                return snapshot.connectionState == ConnectionState.done
                    ? CustomEQ(enableCustomEQ, snapshot.data)
                    : CircularProgressIndicator();
              },
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Presets(enableCustomEQ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomEQ extends StatefulWidget {
  const CustomEQ(this.enabled, this.bandLevelRange);

  final bool enabled;
  final List<int> bandLevelRange;

  @override
  _CustomEQState createState() => _CustomEQState();
}

class _CustomEQState extends State<CustomEQ> {
  @override
  Widget build(BuildContext context) {
    final min = widget.bandLevelRange[0].toDouble();
    final max = widget.bandLevelRange[1].toDouble();
    return StreamBuilder<String>(
      stream: Equalizer.onPresetChanged.distinct(),
      builder: (context, _) {
        int bandId = 0;
        return FutureBuilder<List<int>>(
          future: Equalizer.getCenterBandFreqs(),
          builder: (context, snapshot) {
            return snapshot.connectionState == ConnectionState.done
                ? Row(
                    children: snapshot.data
                        .map((freq) =>
                            _buildSliderBand(min, max, freq, bandId++))
                        .toList(),
                  )
                : CircularProgressIndicator();
          },
        );
      },
    );
  }

  Widget _buildSliderBand(double min, double max, int freq, int bandId) {
    return Column(
      children: [
        SizedBox(
          height: 250.0,
          child: FutureBuilder<int>(
            future: Equalizer.getBandLevel(bandId),
            builder: (context, snapshot) {
              return FlutterSlider(
                disabled: !widget.enabled,
                axis: Axis.vertical,
                rtl: true,
                min: min,
                max: max,
                values: snapshot.hasData ? [snapshot.data.toDouble()] : [0],
                onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                  Equalizer.setBandLevel(bandId, lowerValue.toInt());
                },
              );
            },
          ),
        ),
        Text('${freq ~/ 1000} Hz'),
      ],
    );
  }
}

class Presets extends StatefulWidget {
  const Presets(this.enabled);

  final bool enabled;

  @override
  _PresetsState createState() => _PresetsState();
}

class _PresetsState extends State<Presets> {
  String _selectedValue;
  Future<List<String>> fetchPresets;

  @override
  void initState() {
    super.initState();
    fetchPresets = Equalizer.getPresetNames();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: fetchPresets,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final presets = snapshot.data;
          if (presets.isEmpty) return Text('No presets available!');
          return DropdownButtonFormField(
            decoration: InputDecoration(
              labelText: 'Available Presets',
              border: OutlineInputBorder(),
            ),
            value: _selectedValue,
            onChanged: widget.enabled
                ? (String value) {
                    Equalizer.setPreset(value);
                    setState(() {
                      _selectedValue = value;
                    });
                  }
                : null,
            items: presets.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          );
        } else if (snapshot.hasError)
          return Text(snapshot.error);
        else
          return CircularProgressIndicator();
      },
    );
  }
}

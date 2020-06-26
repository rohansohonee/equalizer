import 'package:equalizer/equalizer.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Equalizer Plugin example app'),
        ),
        body: Center(
          child: FlatButton.icon(
            icon: Icon(Icons.equalizer),
            label: Text('Open equalizer'),
            color: Colors.blue,
            textColor: Colors.white,
            onPressed: () => Equalizer.openEqualizer(0),
          ),
        ),
      ),
    );
  }
}

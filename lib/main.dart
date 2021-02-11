import 'package:flutter/material.dart';
import 'package:control_pad/control_pad.dart';
import 'package:flutter/services.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'dart:math';
//import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,]);
    return MaterialApp(
      title: 'Forklift Remote',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Forklift Remote'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> {
  //int _counter = 0;

  void _incrementCounter() {
    setState(() {
    //  _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            JoystickView(
              onDirectionChanged: (deg,val){
                double hor = (sin(deg/360*(2*pi))*val);
                double shor = hor.sign;
                double ver = (cos(deg/360*(2*pi))*val);
                double sver = ver.sign;
                int left = (((sver)*pow(ver, 2) + (shor)*pow(hor, 2))*255).round();
                int right = (((sver)*pow(ver, 2) - (shor)*pow(hor, 2))*255).round();
                print('left $left right $right');},
            ),
            ToggleSwitch(
              initialLabelIndex: 1,
              labels: ['Up','Stop','Down'],
              icons: [Icons.arrow_upward, Icons.stop, Icons.arrow_downward],
              onToggle: (index) {
                print('switched to: $index');
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

import 'package:flutter/material.dart';
import 'package:control_pad/control_pad.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
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
  BluetoothConnection connection;
  String t = "";
  int l = 0;
  int r = 0;
  String toSend = "";
  int sn = 0;
  String st = "";

  void sending() async {
    String c1 = "";
    String c2 = "";
    String m1 = "";
    String m2 = "";
    if(l > 0){
      c1 = "C,1,1";
    }else{
      c1 = "C,1,2";
    }
    if(r>0){
      c2 = "C,2,1";
    }
    else{
      c2 = "C,2,2";
    }
    m1 = "M,1," + l.toInt().abs().toString();
    m2 = "M,2," + r.toInt().abs().toString();
    toSend = c1+c2+m1+m2+st;
    st = "";
    connection.output
        .add(Uint8List.fromList(ascii.encode(toSend)));
    await Future.delayed(Duration(milliseconds: 66));
    sending();
  }

  void bt() async {
    try {
      connection = await BluetoothConnection.toAddress("00:19:10:08:D5:05");
      setState(() {
        t = "Connected to the device";
      });

      print(t);
      if(sn == 0){
        sending();
        sn = 1;
      }

      connection.input.listen((Uint8List data) {
        print('Data incoming: ${ascii.decode(data)}');
      }).onDone(() {
        setState(() {
          t = 'Disconnected by remote request';
        });

        print(t);
      });
    } catch (exception) {
      setState(() {
        t = 'Cannot connect, exception occured: ' + exception;
      });

      print(t);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(children: <Widget>[
          Text(t),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              JoystickView(
                onDirectionChanged: (deg, val) {
                  double hor = (sin(deg / 360 * (2 * pi)) * val);
                  double shor = hor.sign;
                  double ver = (cos(deg / 360 * (2 * pi)) * val);
                  double sver = ver.sign;
                  int left =
                      (((sver) * pow(ver, 2) + (shor) * pow(hor, 2)) * 255)
                          .round();
                  int right =
                      (((sver) * pow(ver, 2) - (shor) * pow(hor, 2)) * 255)
                          .round();
                  //print('left $left right $right');
                  l = left;
                  r = right;
                },
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_upward),
                    onPressed: () {
                      st = "S";
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_downward),
                    onPressed: () {
                      st = "s";
                    },
                  ),
                ],
              )
            ],
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: bt,
        tooltip: 'Connect',
        child: Icon(Icons.bluetooth_connected),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

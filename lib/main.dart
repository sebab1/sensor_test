import 'dart:core';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:location/location.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Sensor Test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  // For the Gyroscope
  double x = 0;
  double y = 0;
  double z = 0;
  String direction = "none";

  // For the Location
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  LocationData? _userLocation;

  Future<void> _getUserLocation() async {
    Location location = Location();

    // Check if location service is enable
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // Check if permission is granted
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    final _locationData = await location.getLocation();
    setState(() {
      _userLocation = _locationData;
    });
  }

  void initState() {
    gyroscopeEvents.listen((GyroscopeEvent event) {
      print(event);

      x = event.x;
      y = event.y;
      z = event.z;

      if (x > 0) {
        direction = "Back";
      } else if (x < 0) {
        direction = "Forward";
      } else if (y > 0) {
        direction = "Left";
      } else if (y < 0) {
        direction = "Right";
      } else if (z > 0) {
        direction = "Up";
      } else if (z < 0) {
        direction = "Down";
      }

      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gyroscope and Location Test"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ElevatedButton(onPressed: _getUserLocation, child: const Text("See location")),
            const SizedBox(height: 25),
            _userLocation != null
              ? Padding(
              padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  children: [
                    Text('Your latitude: ${_userLocation?.latitude}'),
                    const SizedBox(width: 10,),
                    Text('Your longitude: ${_userLocation?.longitude}')
                  ],
                ),)
            : Padding(padding: const EdgeInsets.all(10)),
            Text(direction, style: TextStyle(fontSize: 30),),
            Table( //Table for Gyroscope data
              border: TableBorder.all(width: 2.0, style: BorderStyle.solid),
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("X axis: ", style: TextStyle(fontSize: 20.0)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(x.toStringAsFixed(2), style: TextStyle(fontSize: 20.0)),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Y axis: ", style: TextStyle(fontSize: 20.0)),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                      child: Text(y.toStringAsFixed(2), style: TextStyle(fontSize: 20.0)),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Z axis: ", style: TextStyle(fontSize: 20.0)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(z.toStringAsFixed(2), style: TextStyle(fontSize: 20.0)),
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      )); // This trailing comma makes auto-formatting nicer for build methods
  }
}

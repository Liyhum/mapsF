import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  return await Geolocator.getCurrentPosition();
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  late GoogleMapController googleMapController;
  late String searchAdd = "Jakarta";
  late LatLng currentPostion;

  void _getUserLocation() async {
    print("Starting Get User");
    var position = await GeolocatorPlatform.instance
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print("${position.latitude} ${position.longitude} Lat");
    setState(() {

      currentPostion = LatLng(position.latitude, position.longitude);
    });
  }
  void initState(){
    _determinePosition();
    super.initState();
    // _getUserLocation();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: <Widget>[
            GoogleMap(
              onMapCreated: onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(-6.3482321 ,106.7125259),
                zoom: 5,
              ),
            ),
          Positioned(
            top: 30,
            right:15.0,
            left:15.0,
            child: Container(
              child: TextField(
                onChanged: (val){
                  setState(() {
                    searchAdd = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Cari Alamat",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 15.0,top: 15.0),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: searchandNavigate(),
                    iconSize:30.0
                  )
                )
              ),
              height: 50,
              width: double.infinity,
              decoration:BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white,
              ),
            ),
          )
        ],
      )
    );
  }


  searchandNavigate(){
    locationFromAddress(searchAdd).then((result){

      googleMapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(result[0].latitude, result[0].longitude),
        zoom: 10,
      )));
    });
  }

  void onMapCreated(controller){
    setState(() {
      googleMapController = controller;
    });
  }
}

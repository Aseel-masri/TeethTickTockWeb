import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:untitled/maps/nearest.dart';

class Doc_locations extends StatelessWidget {
  final List doctor_category;
  Doc_locations({required this.doctor_category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.location_on,
              color: Colors.red,
              size: 30,
            ),
            Text('  Dental Clinic Location'),
          ],
        ),
        backgroundColor: Color(0xFF389AAB),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: MapSample(id: doctor_category),
    );
  }
}

class MapSample extends StatefulWidget {
  final List id;

  MapSample({required this.id});
  @override
  State<MapSample> createState() => MapSampleState(doctors_loc: id);
}

class MapSampleState extends State<MapSample> {
  final List doctors_loc;

  MapSampleState({required this.doctors_loc});
  late GoogleMapController mapController;
  late  LatLngClass userLocation;
  List<LatLng> myMarkerPosition = [LatLng(32.215662, 35.2667611)];

  //get responseMap => null; // Initial marker position
  List<String> name = ['Aseel'];
    late Position currentLocation;
  Future<Position> _getLongLat() async {
    var pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
   /*  var lastMsg = await Geolocator.getLastKnownPosition();
    print("getLastKnownPosition $lastMsg"); */

    return pos;
    // return await Geolocator.getCurrentPosition().then((value) => value);
  }
  List<List<double>> doctorLocations=[];
    Future _getLocation() async {
    bool service;
    var per;
    try {
      service = await Geolocator.isLocationServiceEnabled();
      print("Aseel1");
      if (service == false) {
        print("Aseel2.1");
        AwesomeDialog(
           width: MediaQuery.of(context).size.width * 0.45,
            context: context,
            title: 'service',
            body: Text("Service Not Enabled"))
          ..show();
      }
      print("Aseel2.2");
      per = await Geolocator.checkPermission();
      print("Aseel3");
      // LocationPermission permission = await Geolocator.requestPermission();

      if (per == LocationPermission.denied) {
        // throw 'Location permissions are denied.';
        per = await Geolocator.requestPermission();
        print("Aseel4.1");
      }
      if (per == LocationPermission.always) {
        print("Aseel4.2");
      }
      print("Aseel4.3");
      currentLocation = await _getLongLat();
      print("Aseel4.3");
      print("Latitude: ${currentLocation.latitude}");
      print("Longitude: ${currentLocation.longitude}");
      setState(() {
       userLocation=  LatLngClass(currentLocation.latitude, currentLocation.longitude);
           setState(() {
      var temp_loc;
      myMarkerPosition.clear();
      name.clear();
      for (int i = 0; i < doctors_loc.length; i++) {
        double latitude = doctors_loc[i]['locationMap']?[0]; // 32.22219
        double longitude = doctors_loc[i]['locationMap']?[1];
        doctorLocations.add([latitude, longitude]);
        temp_loc = LatLng(latitude, longitude);
        myMarkerPosition.add(temp_loc);
        name.add(doctors_loc[i]['name']!);
      }
      double maxDistance =
          10.0; // Set your maximum distance threshold in kilometers

      List<LatLngClass> nearestLocations =
          findNearestLocations(doctorLocations, userLocation, maxDistance);

      print(
          'Nearest doctor locations within $maxDistance km: $nearestLocations');
    });
   /*      globallatitude = currentLocation.latitude;
        globallongitude = currentLocation.longitude;
        myMarkerPosition =
            LatLng(currentLocation.latitude, currentLocation.longitude); */
      });
      //  Position position = await Geolocator.getCurrentPosition().then((value) => value);
    } catch (e) {
      print("Error getting location: $e");
    }
  }
    void initializeData() async {
    await _getLocation();
  }
  @override
  void initState() {
    
    super.initState();
    initializeData();
    print(
        "LOCATION****************************************************************");


  }

  Set<Marker> _createMarkers() {
    Set<Marker> markers = Set();

    for (int i = 0; i < myMarkerPosition.length; i++) {
      markers.add(
        Marker(
          markerId: MarkerId('myMarker$i'),
          position: myMarkerPosition[i],
          infoWindow: InfoWindow(
            title: name[i],
            snippet: 'Dental Clinic',
          ),
          onTap: () {},
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: (controller) {
        mapController = controller;
      },
      initialCameraPosition: CameraPosition(
        target: myMarkerPosition[
            0], // Use the myMarkerPosition as the initial position
        zoom: 12,
      ),
      markers: _createMarkers()
      /*  {
        Marker(
          markerId: MarkerId('myMarker'),
          position: myMarkerPosition,
          infoWindow: InfoWindow(title: name, snippet: 'Dental Clinic'),
          onTap: () {
            // Handle marker tap here if needed
          },
        ),
      } */
      ,
      onTap: (LatLng position) async {},
    );
  }
}

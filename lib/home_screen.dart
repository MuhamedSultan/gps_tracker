import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription<LocationData>? trackerService;
  var locationManager = Location();
  GoogleMapController? _controller;
  static const String routeMarkerId = "route-Dokki";
  static const String userMarkerId = "user-marker";
  static var routeDokki = const CameraPosition(
    target: LatLng(30.0358676, 31.1965055),
    zoom: 16,
  );
  Set<Marker> markerSet = {
    const Marker(
        markerId: MarkerId(routeMarkerId),
        position: LatLng(30.0358676, 31.1965055))
  };

  @override
  void initState() {
    super.initState();
    askUserForPermissionAndService();
  }


  void trackUserLocation() async {
    var canGetLocation = await canUseGps();
    if (!canGetLocation) return;
    locationManager.changeSettings(
      //change provider -> get location from gps->high / get location from network->low
      accuracy: LocationAccuracy.high,
      // get new location after 0 m
      // distanceFilter: 0,
      // get new location after 1S
      // interval: 1000,
    );
    trackerService = locationManager.onLocationChanged.listen((locationData) {
      markerSet.add(Marker(
          markerId:const MarkerId(userMarkerId),
          position: LatLng(
              locationData.latitude ?? 0.0, locationData.longitude ?? 0.0)));

      _controller?.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(locationData.latitude ?? 0.0, locationData.longitude ?? 0.0),
          16));
      setState(() { });
    });
  }

  @override
  void dispose() {
    trackerService?.cancel();
    super.dispose();
  }

  void askUserForPermissionAndService() async {
    await requestPermission();
    await requestService();
    // getUserLocation();
    trackUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Gps tracker",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
              child: GoogleMap(
            markers: markerSet,
            mapType: MapType.normal,
            initialCameraPosition: routeDokki,
            onMapCreated: (GoogleMapController controller) {
              _controller = (controller);
              drawUserMarker();
            },
          )),
          ElevatedButton(onPressed: () {
            trackUserLocation();
          }, child: const Text('Start tracking'))
        ],
      ),
    );
  }

  void drawUserMarker() async {
    var canGetLocation = await canUseGps();
    if (!canGetLocation) return;
    var locationData = await locationManager.getLocation();
    _controller?.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(locationData.latitude ?? 0.0, locationData.longitude ?? 0.0),
        16));
    markerSet.add(Marker(
        markerId:const MarkerId(userMarkerId),
        position: LatLng(
            locationData.latitude ?? 0.0, locationData.longitude ?? 0.0)));
    setState(() {});
  }

  void getUserLocation() async {
    var canGetLocation = await canUseGps();
    if (!canGetLocation) return;
    var location = await locationManager.getLocation();
    print(location.longitude);
    print(location.latitude);

  }

  Future<bool> canUseGps() async {
    var permissionGranted = await isPermissionGranted();
    if (!permissionGranted) {
      return false;
    }
    var isServiceEnabled = await isLocationServiceEnabled();
    if (!isServiceEnabled) {
      return false;
    }
    return true;
  }

  Future<bool> isLocationServiceEnabled() async {
    return await locationManager.serviceEnabled();
  }

  Future<bool> requestService() async {
    var enabled = await locationManager.requestService();
    return enabled;
  }

  Future<bool> isPermissionGranted() async {
    var permissionStatus = await locationManager.hasPermission();
    return permissionStatus == PermissionStatus.granted;
  }

  Future<bool> requestPermission() async {
    var permissionStatus = await locationManager.requestPermission();
    return permissionStatus == PermissionStatus.granted;
  }
}

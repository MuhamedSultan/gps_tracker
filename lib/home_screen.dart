import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var locationManager = Location();

  @override
  void initState() {
    super.initState();
    askUserForPermissionAndService();
  }

  void getUserLocation() async {
    var canGetLocation = await canUseGps();
    if (!canGetLocation) return;
    var location = await locationManager.getLocation();
    print(location.longitude);
    print(location.latitude);
    print(location.satelliteNumber);
    print(location.time);
  }

  StreamSubscription<LocationData>? trackerService = null;

  void trackUserLocation() async {
    var canGetLocation = await canUseGps();
    if (!canGetLocation) return;
    locationManager.changeSettings(
      //change provider -> get location from gps->high / get location from network->low
      accuracy: LocationAccuracy.high,
      // get new location after 0 m
      distanceFilter: 0,
      // get new location after 1S
      interval: 1000,
    );
    trackerService = locationManager.onLocationChanged.listen((locationData) {
      print(locationData.longitude);
      print(locationData.latitude);
      print(locationData.satelliteNumber);
      print(locationData.time);
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
      
    );
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

import 'package:flutter/material.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';
import 'package:geolocator/geolocator.dart';

class MapView extends StatefulWidget {
  const MapView(
      {super.key,
      required this.destinationLatitude,
      required this.destinationLongitude});

  final double destinationLatitude;
  final double destinationLongitude;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  MapBoxNavigationViewController? _controller;
  String? _instruction;
  bool _isMultipleStop = false;
  double? _distanceRemaining, _durationRemaining;
  bool _routeBuilt = false;
  bool _isNavigating = false;
  bool _arrived = false;
  late MapBoxOptions _navigationOption;
  bool _isInitialized = false; // Add this line

  Future<void> initialize() async {
    if (!mounted) return;
    Position location = await _determinePosition();
    _navigationOption = MapBoxOptions(
        initialLatitude: location.latitude,
        initialLongitude: location.longitude,
        zoom: 15.0,
        tilt: 0.0,
        bearing: 0.0,
        enableRefresh: false,
        alternatives: true,
        voiceInstructionsEnabled: true,
        bannerInstructionsEnabled: true,
        allowsUTurnAtWayPoints: true,
        mode: MapBoxNavigationMode.drivingWithTraffic,
        units: VoiceUnits.imperial,
        simulateRoute: true,
        language: "vi",
        longPressDestinationEnabled: false, // Explicitly set to false
        animateBuildRoute: false // Explicitly set to false
        );
    await MapBoxNavigation.instance.registerRouteEventListener(_onRouteEvent);
    setState(() {
      _isInitialized = true; // Set _isInitialized to true after initialization
    });
  }

  @override
  void initState() {
    initialize();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (_isInitialized) // Check if initialization is complete
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Container(
                color: Colors.grey[100],
                child: MapBoxNavigationView(
                  options: _navigationOption,
                  onRouteEvent: _onRouteEvent,
                  onCreated: (MapBoxNavigationViewController controller) async {
                    try {
                      _controller = controller;
                      await controller.initialize();
                      Position location = await _determinePosition();
                      var origin = WayPoint(
                          name: 'origin',
                          latitude: location.latitude,
                          longitude: location.longitude);

                      print('origin: ' + origin.toString());

                      var destination = WayPoint(
                          name: 'destination',
                          latitude: widget.destinationLatitude,
                          longitude: widget.destinationLongitude);

                      print('destination: ' + destination.toString());
                      
                      var wayPoints = [origin, destination];

                      await _controller?.buildRoute(wayPoints: wayPoints);
                      await _controller?.startNavigation();
                    } catch (e) {
                      print('Error initializing MapBox navigation: $e');
                    }
                  },
                ),
              ),
            ),
          if (!_isInitialized) // Optional: show a loading indicator while initializing
            Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

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

  Future<void> _onRouteEvent(e) async {
    _distanceRemaining = await MapBoxNavigation.instance.getDistanceRemaining();
    _durationRemaining = await MapBoxNavigation.instance.getDurationRemaining();

    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        _arrived = progressEvent.arrived!;
        if (progressEvent.currentStepInstruction != null)
          _instruction = progressEvent.currentStepInstruction;
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        _routeBuilt = true;
        break;
      case MapBoxEvent.route_build_failed:
        _routeBuilt = false;
        break;
      case MapBoxEvent.navigation_running:
        _isNavigating = true;
        break;
      case MapBoxEvent.on_arrival:
        _arrived = true;
        if (!_isMultipleStop) {
          await Future.delayed(Duration(seconds: 3));
          await _controller?.finishNavigation();
        } else {}
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        _routeBuilt = false;
        _isNavigating = false;
        break;
      default:
        break;
    }
    //refresh UI
    setState(() {});
  }
}

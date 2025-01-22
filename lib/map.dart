import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps; // Alias for google_maps
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart' as latlong; // Alias for latlong2
import 'package:geolocator/geolocator.dart';

class Mappage extends StatefulWidget {
  const Mappage({super.key});

  @override
  State<Mappage> createState() => _MappageState();
}

class _MappageState extends State<Mappage> {
  latlong.LatLng? _tappedLocation; // Use latlong.LatLng
  TextEditingController _searchController = TextEditingController();
  late MapController _mapController;
  bool _isLoading = false;
  String? _locationName;
  List<String> _suggestions = [];
  String? _locationData; // To store location data from backend
  List<dynamic> _nearbyParlours = []; // To store nearby parlours

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _checkLocationPermission(); // Check location permission on init
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _getCurrentLocation();
    } else {
      _showLocationPermissionDialog();
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationServiceDialog();
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _tappedLocation = latlong.LatLng(position.latitude, position.longitude); // Use latlong.LatLng
      _mapController.move(_tappedLocation!, 13.0);
    });

    // Send location to backend with GET request
    await _fetchLocationFromBackend(
        position.latitude, position.longitude);
  }

  Future<void> _fetchLocationFromBackend(
      double latitude, double longitude) async {
    final url = Uri.parse(
        "http://192.168.1.35:8086/user/userLocation?latitude=$latitude&longitude=$longitude");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Cookie':
              'JSESSIONID=15934606EAE51F4998403EE31B6F0A3B', // Replace with your session ID
        },
      );

      if (response.statusCode == 200) {
        print("Location fetched successfully: ${response.body}");
        final data = jsonDecode(response.body); // parse response if JSON
        // handle your response data here
      } else {
        print("Failed to fetch location. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching location from backend")),
      );
    }
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enable Location Services"),
          content: Text("Please enable location services to use this feature."),
          actions: [
            TextButton(
              child: Text("Open Settings"),
              onPressed: () {
                Geolocator.openLocationSettings();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Location Permission Required"),
          content:
              Text("Please grant location permission to use this feature."),
          actions: [
            TextButton(
              child: Text("Open Settings"),
              onPressed: () {
                Geolocator.openAppSettings();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Nearby Parlours"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search location',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: (value) {
                print("Search input: $value"); // Debug statement
                if (value.isNotEmpty) {
                  _fetchSuggestions(value);
                } else {
                  setState(() {
                    _suggestions.clear();
                  });
                }
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _searchLocation(value);
                }
              },
            ),
          ),
          if (_suggestions.isNotEmpty)
            Container(
              height: 150,
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_suggestions[index]),
                    onTap: () {
                      _searchController.text = _suggestions[index];
                      _searchLocation(_suggestions[index]);
                      setState(() {
                        _suggestions.clear(); // Clear suggestions after selection
                      });
                    },
                  );
                },
              ),
            ),
          if (_isLoading) Center(child: CircularProgressIndicator()),
          Expanded(child: content()),
          if (_locationName != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Location: $_locationName"),
            ),
          if (_locationData != null) // Add this part to display location data
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Location Data: $_locationData"),
            ),
          if (_nearbyParlours.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nearby Parlours:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  for (var parlour in _nearbyParlours)
                    Text(parlour['name']), // Display parlour names
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget content() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: latlong.LatLng(9.4981, 76.3388), // Use latlong.LatLng
        initialZoom: 8,
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.all,
        ),
        onTap: (tapPosition, point) {
          _placeMarker(point);
        },
      ),
      children: [
        openStreetMapTileLayer,
        MarkerLayer(markers: [
          if (_tappedLocation != null)
            Marker(
              point: _tappedLocation!, // Use latlong.LatLng
              width: 60,
              height: 60,
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  _showLocationDetails();
                },
                child: Icon(
                  Icons.location_pin,
                  size: 50,
                  color: Colors.red,
                ),
              ),
            ),
        ]),
      ],
    );
  }

  void _fetchSuggestions(String query) async {
    final url =
        "https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5";

    print("Fetching suggestions for: $query"); // Debug statement
    try {
      final response = await http.get(Uri.parse(url));
      print("Response status: ${response.statusCode}"); // Debug statement

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List data = json.decode(response.body);
        setState(() {
          _suggestions =
              data.map((item) => item['display_name'] as String).toList();
        });
        print("Suggestions: $_suggestions"); // Debug statement
      }
    } catch (e) {
      print("Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch suggestions")),
      );
    }
  }

  void _placeMarker(latlong.LatLng point) async { // Use latlong.LatLng
    // Reverse geocoding to get location details (optional)
    final url =
        "https://nominatim.openstreetmap.org/reverse?lat=${point.latitude}&lon=${point.longitude}&format=json";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // You can still get the location name if needed, but it's not necessary for your requirement
        final data = json.decode(response.body);
        String locationName = data['display_name'];

        setState(() {
          _tappedLocation = point;
          _mapController.move(point, 13.0);
        });

        // Return the selected latitude and longitude back to the previous page
        Navigator.pop(context, {
          'latitude': point.latitude,
          'longitude': point.longitude,
        });
      }
    } catch (e) {
      print("Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to get location details")),
      );
    }
  }

  void _showLocationDetails() {
    if (_locationName != null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Location Details"),
            content: Text("You are at: $_locationName"),
            actions: [
              TextButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _searchLocation(String query) async {
    final url =
        "https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        if (results.isNotEmpty) {
          final firstResult = results[0];
          final lat = firstResult['lat'];
          final lon = firstResult['lon'];
          final locationName = firstResult['display_name'];

          // Instead of placing a marker directly, call the _placeMarker method
          _placeMarker(latlong.LatLng(double.parse(lat), double.parse(lon))); // Use latlong.LatLng

          // Update the text field
          setState(() {
            _searchController.text = locationName; // Update text field
          });
        }
      }
    } catch (e) {
      print("Error searching location: $e");
    }
  }
}

TileLayer get openStreetMapTileLayer => TileLayer(
      urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
    );

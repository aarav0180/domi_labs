import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class LocationProvider with ChangeNotifier {
  LatLng? userLocation;
  String currentLocationName = 'Fetching location...';

  Future<LatLng> fetchUserLocation() async {
    try {
      Position position = await _determinePosition();
      userLocation = LatLng(position.latitude, position.longitude);

      await getLocationName(position.latitude, position.longitude);

      notifyListeners();
      return userLocation!;
    } catch (e) {
      print('Error fetching user location: $e');
      rethrow;
    }
  }

  // Move the map to the user's current location
  Future<void> showCurrentLocation(MapController mapController) async {
    if (userLocation != null) {
      mapController.move(userLocation!, 15.0);
    }
  }

  Future<void> getLocationName(double latitude, double longitude) async {
    try {
      String locationName = await fetchLocationName(latitude, longitude);
      String shortLocationName = locationName.length > 14
          ? locationName.substring(0, 14) + "..."
          : locationName;

      currentLocationName = shortLocationName;
      notifyListeners();
    } catch (e) {
      print('Error fetching location name: $e');
      currentLocationName = 'Unknown location';
      notifyListeners();
    }
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

  Future<String> fetchLocationName(double latitude, double longitude) async {
    final response = await http.get(
      Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['display_name'] ?? 'Unknown location';
    } else {
      throw Exception('Failed to fetch location name');
    }
  }
}




// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:latlong2/latlong.dart';
//
// class LocationProvider with ChangeNotifier {
//   LatLng? myLocation;
//   String currentLocationName = 'Fetching location...';
//
//   Future<void> showCurrentLocation(MapController mapController) async {
//     Position position = await _determinePosition();
//     myLocation = LatLng(position.latitude, position.longitude);
//     mapController.move(myLocation!, 13.0);
//     notifyListeners();
//   }
//
//   Future<void> getLocationName(double latitude, double longitude) async {
//     String locationName = await fetchLocationName(latitude, longitude);
//
//     String shortLocationName = locationName.length > 14
//         ? locationName.substring(0, 14) + "..."
//         : locationName;
//     currentLocationName = shortLocationName;
//     notifyListeners();
//   }
//
//   Future<Position> _determinePosition() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return Future.error('Location services are disabled.');
//     }
//
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permissions are denied');
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       return Future.error('Location permissions are permanently denied, we cannot request permissions.');
//     }
//
//     return await Geolocator.getCurrentPosition();
//   }
//
//   Future<String> fetchLocationName(double latitude, double longitude) async {
//     final response = await http.get(
//       Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude'),
//     );
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       return data['display_name'] ?? 'Unknown location';
//     } else {
//       return 'Unknown location';
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MarkerProvider with ChangeNotifier {
  List<Marker> _markers = [];

  List<Marker> get markers => _markers;

  void addMarker(LatLng position) {
    _markers.add(
      Marker(
        width: 80.0,
        height: 80.0,
        point: position,
        child:  const Icon(Icons.location_on, color: Colors.red, size: 40),
      ),
    );
    notifyListeners();
  }

  void removeMarker(LatLng position) {
    _markers.removeWhere((marker) => marker.point == position);
    notifyListeners();
  }
}

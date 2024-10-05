import 'dart:async';

import 'package:domi_labs/Pages/Detailpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../Provider/location_provider.dart';
import '../Provider/marker_provider.dart';
import 'custom_marker.dart';

class SuggestionPage extends StatefulWidget {
  const SuggestionPage({super.key});

  @override
  State<SuggestionPage> createState() => _SuggestionPageState();
}

class _SuggestionPageState extends State<SuggestionPage> {
  final MapController _mapController = MapController();
  bool showInviteBox = false;
  bool showDraggableSheet = true;
  LatLng? userLocation;
  static const double inviteRadius = 300.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {

      LatLng userLoc = await Provider.of<LocationProvider>(context, listen: false)
          .fetchUserLocation();

      Provider.of<LocationProvider>(context, listen: false)
          .showCurrentLocation(_mapController);

      setState(() {
        userLocation = userLoc;
      });
    });
  }

  Future<void> onMapTapped(LatLng latLng) async {
    if (userLocation == null) return;

    double distanceInMeters = Geolocator.distanceBetween(
      userLocation!.latitude,
      userLocation!.longitude,
      latLng.latitude,
      latLng.longitude,
    );

    if (distanceInMeters <= inviteRadius) {
      setState(() {
        showInviteBox = true;
        showDraggableSheet = false;
      });
    } else {
      Fluttertoast.showToast(
        msg: "The distance is too much!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final markerProvider = Provider.of<MarkerProvider>(context);

    // Add marker at the user's location
    final markerList = <Marker>[];
    if (userLocation != null) {
      markerList.add(
        Marker(
          point: userLocation!,
          child: SizedBox(
            width: 50,
            height: 50,
            child: CustomPaint(
              painter: CustomMarkerPainter(), // Your custom marker painter
            ),
          ),
        ),
      );
    }

    // Combine user's marker with other markers from markerProvider
    markerList.addAll(markerProvider.markers);

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialZoom: 13.0,
              initialCenter: userLocation ?? LatLng(25.430, 81.772), // Fallback location
              onTap: (tapPosition, latlng) {
                onMapTapped(latlng);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              MarkerLayer(markers: markerList), // Include all markers
            ],
          ),
          _buildTopOverlay(locationProvider.currentLocationName),
          if (showInviteBox) _buildInviteBox(),
          if (showDraggableSheet) _buildDraggableSheet(locationProvider),
        ],
      ),
    );
  }

  Widget _buildTopOverlay(String currentLocationName) {
    return Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Detailpage()));
              },
              icon: const Icon(Icons.person, color: Colors.white),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(36),
            ),
            child: Row(
              children: [
                ClipOval(
                  child: Image.network(
                    'https://picsum.photos/100',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  currentLocationName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Detailpage()));
              },
              icon: const Icon(Icons.message_outlined, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Invite box using CustomPainter
  Widget _buildInviteBox() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: CustomPaint(
        painter: InviteBoxPainter(),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Invite & Earn",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showInviteBox = false;
                        showDraggableSheet = true;
                      });
                    },
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "Invite your neighbor and you both receive \$10 when they claim their address.",
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Detailpage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.white,
                  ),
                  child: const Text(
                    "Send invite",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableSheet(LocationProvider locationProvider) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 15),
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                _buildImageSection(),
                const SizedBox(height: 20),
                _buildDocSection(locationProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('dōmi in', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24))],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(4, (index) => _buildImageCard()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard() {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.network(
          'https://picsum.photos/100',
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildDocSection(LocationProvider locationProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:  [
                Text(
                  'dōmi docs',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    color: Colors.white),
              ],
            ),
            const SizedBox(height: 10),

            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Search docs',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            _buildDocItem('100 Martinique Ave Title',
                'Opened Dec 4, 2023'),
            const SizedBox(
              height: 20,
            ),
            _buildDocItem(
                'Chase Bank Statement - November 2023',
                'Opened Dec 3, 2023'),
            const SizedBox(
              height: 20,
            ),
            _buildDocItem('Backyard Remodel Renderings',
                'Opened Nov 11, 2023'),
          ],
        ),
      ),
    );
  }

  Widget _buildDocItem(String title, String subtitle) {
    return Container(
      decoration:
      BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: ListTile(
          leading: Icon(Icons.file_copy, color: Colors.redAccent),
          title: Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: Colors.grey[400]),
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
        ),
      ),
    );
  }
}

// CustomPainter for InviteBox
class InviteBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTRB(0, 0, size.width, size.height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(15)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}




// import 'dart:async';
//
// import 'package:domi_labs/Pages/Detailpage.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:provider/provider.dart';
//
// import '../Provider/location_provider.dart';
// import '../Provider/marker_provider.dart';
//
//
// class SuggestionPage extends StatefulWidget {
//   const SuggestionPage({super.key});
//
//   @override
//   State<SuggestionPage> createState() => _SuggestionPageState();
// }
//
// class _SuggestionPageState extends State<SuggestionPage> {
//   final MapController _mapController = MapController();
//   bool showInviteBox = false;
//   bool showDraggableSheet = true;
//   int _tapCount = 0;
//   Timer? _tapTimer;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<LocationProvider>(context, listen: false).showCurrentLocation(_mapController);
//     });
//   }
//
//   void onMapTapped(LatLng latLng) async {
//     Provider.of<LocationProvider>(context, listen: false).getLocationName(latLng.latitude, latLng.longitude);
//
//     setState(() {
//       showInviteBox = true;
//       showDraggableSheet = false;
//     });
//     // if (_tapTimer != null && _tapTimer!.isActive) {
//     //   _tapTimer!.cancel();
//     //   _handleDoubleTap(latLng);
//     // } else {
//     //   _tapCount++;
//     //   _tapTimer = Timer(const Duration(milliseconds: 300), () {
//     //     _tapCount = 0;
//     //   });
//     // }
//   }
//
//   // void _handleDoubleTap(LatLng latLng) {
//   //   // setState(() {
//   //   //   showInviteBox = true;
//   //   //   showDraggableSheet = false;
//   //   // });
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     final locationProvider = Provider.of<LocationProvider>(context);
//     final markerProvider = Provider.of<MarkerProvider>(context);
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           FlutterMap(
//             mapController: _mapController,
//             options: MapOptions(
//               initialZoom: 13.0,
//               initialCenter: locationProvider.myLocation ?? LatLng(25.430, 81.772),
//               onTap: (tapPosition, latlng) {
//                 onMapTapped(latlng);
//               },
//             ),
//             children: [
//               TileLayer(
//                 urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//               ),
//               MarkerLayer(markers: markerProvider.markers),
//             ],
//           ),
//           _buildTopOverlay(locationProvider.currentLocationName),
//           if (showInviteBox)
//             _buildInviteBox(),
//           if (showDraggableSheet)
//             _buildDraggableSheet(locationProvider),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTopOverlay(String currentLocationName) {
//     return Positioned(
//       top: 50,
//       left: 20,
//       right: 20,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black),
//             child: IconButton(onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => Detailpage()));}, icon: const Icon(Icons.person, color: Colors.white)),
//           ),
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(36)),
//             child: Row(
//               children: [
//                 ClipOval(
//                   child: Image.network(
//                     'https://picsum.photos/100',
//                     width: 50,
//                     height: 50,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 const SizedBox(width: 3),
//                 Text(
//                   currentLocationName,
//                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black),
//             child: IconButton(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => Detailpage()));}, icon: const Icon(Icons.message_outlined, color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInviteBox() {
//     return Positioned(
//       bottom: 20,
//       left: 20,
//       right: 20,
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(15)),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text("Invite & Earn", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
//                 GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       showInviteBox = false;
//                       showDraggableSheet = true;
//                     });
//                   },
//                   child: const Icon(Icons.close, color: Colors.white),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             Text(
//               "Invite your neighbor and you both receive \$10 when they claim their address.",
//               style: TextStyle(color: Colors.grey[400], fontSize: 14),
//             ),
//             const SizedBox(height: 20),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => Detailpage()));},
//                 style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), backgroundColor: Colors.white),
//                 child: const Text(
//                   "Send invite",
//                   style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDraggableSheet(LocationProvider locationProvider) {
//     return DraggableScrollableSheet(
//       initialChildSize: 0.4,
//       minChildSize: 0.2,
//       maxChildSize: 0.8,
//       builder: (context, scrollController) {
//         return Container(
//           decoration: const BoxDecoration(
//             color: Colors.black87,
//             borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
//           ),
//           child: SingleChildScrollView(
//             controller: scrollController,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Container(
//                     margin: const EdgeInsets.only(top: 10, bottom: 15),
//                     height: 4,
//                     width: 40,
//                     decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(10)),
//                   ),
//                 ),
//                 _buildImageSection(),
//                 const SizedBox(height: 20),
//                 _buildDocSection(locationProvider),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildImageSection() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Container(
//         padding: const EdgeInsets.all(15),
//         decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(15)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [Text('dōmi in', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24))],
//             ),
//             const SizedBox(height: 10),
//             SizedBox(
//               height: 100,
//               child: ListView(
//                 scrollDirection: Axis.horizontal,
//                 children: List.generate(4, (index) => _buildImageCard()),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildImageCard() {
//     return Padding(
//       padding: const EdgeInsets.only(right: 10),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(15),
//         child: Image.network(
//           'https://picsum.photos/100',
//           width: 100,
//           height: 100,
//           fit: BoxFit.cover,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDocSection(LocationProvider locationProvider) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Container(
//         padding: const EdgeInsets.all(15),
//         decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(15)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children:  [
//                 Text(
//                   'dōmi docs',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 24,
//                   ),
//                 ),
//                 Icon(Icons.arrow_forward_ios,
//                     color: Colors.white),
//               ],
//             ),
//             const SizedBox(height: 10),
//
//             TextField(
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: Colors.white,
//                 hintText: 'Search docs',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(20),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             _buildDocItem('100 Martinique Ave Title',
//                 'Opened Dec 4, 2023'),
//             const SizedBox(
//               height: 20,
//             ),
//             _buildDocItem(
//                 'Chase Bank Statement - November 2023',
//                 'Opened Dec 3, 2023'),
//             const SizedBox(
//               height: 20,
//             ),
//             _buildDocItem('Backyard Remodel Renderings',
//                 'Opened Nov 11, 2023'),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDocItem(String title, String subtitle) {
//     return Container(
//       decoration:
//       BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         child: ListTile(
//           leading: Icon(Icons.file_copy, color: Colors.redAccent),
//           title: Text(
//             title,
//             style: TextStyle(color: Colors.white),
//           ),
//           subtitle: Text(
//             subtitle,
//             style: TextStyle(color: Colors.grey[400]),
//           ),
//           trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
//         ),
//       ),
//     );
//   }
// }

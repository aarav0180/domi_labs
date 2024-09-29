import 'package:domi_labs/Pages/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Provider/location_provider.dart';
import 'Provider/marker_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => MarkerProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Map Suggestion App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: SuggestionPage(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:music_player/screens/all_songs.dart';
import 'package:music_player/screens/downloads.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        
        body:AllSongs(),
      ),
    );
  }
}

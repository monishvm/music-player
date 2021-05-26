import 'package:flutter/material.dart';
import 'package:music_player/screens/all_songs.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: AllSongs());
  }
}

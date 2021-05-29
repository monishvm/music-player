import 'package:flutter/material.dart';

class Downloads extends StatefulWidget {
  final String url;
  Downloads({this.url});
  @override
  _DownloadsState createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> {
  String url;

  @override
  void initState() {
    super.initState();
    setState(() {
      url = widget.url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(widget.url ?? '')),
    );
  }
}

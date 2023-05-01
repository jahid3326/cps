import 'package:flutter/material.dart';

class ZoomImage extends StatefulWidget {
  const ZoomImage({super.key});

  @override
  State<ZoomImage> createState() => _ZoomImageState();
}

class _ZoomImageState extends State<ZoomImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zoom Content'),
      ),
      body: Center(
        child: InteractiveViewer(
          // clipBehavior: Clip.none,
          child: Image.asset('assets/images/cps_logo.png')
        ),
      ),
    );
  }
}
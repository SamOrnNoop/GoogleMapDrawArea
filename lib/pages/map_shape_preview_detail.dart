import 'package:flutter/material.dart';

class PreviewGoogleMapDetailPolyLinePage extends StatefulWidget {
  const PreviewGoogleMapDetailPolyLinePage({super.key});

  @override
  State<PreviewGoogleMapDetailPolyLinePage> createState() => _PreviewGoogleMapDetailPolyLinePageState();
}

class _PreviewGoogleMapDetailPolyLinePageState extends State<PreviewGoogleMapDetailPolyLinePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Preview GoogleMap"),
      ),
    );
  }
}

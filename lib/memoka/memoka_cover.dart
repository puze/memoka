import 'package:flutter/material.dart';

class MemokaCover extends StatelessWidget {
  final String coverText;
  const MemokaCover({Key? key, required this.coverText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Image.asset(
        'assets/memoka.png',
      ),
      Positioned(child: Text(coverText))
    ]);
  }
}

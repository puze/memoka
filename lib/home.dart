import 'package:flutter/material.dart';
import 'package:memoka/memoka_body.dart';

class MemokaHome extends StatelessWidget {
  const MemokaHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Scaffold(body: MemokaBody())),
            );
          },
          icon: Icon(Icons.arrow_forward),
          label: Text('Start')),
    );
  }
}

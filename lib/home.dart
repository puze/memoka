import 'package:flutter/material.dart';
import 'package:memoka/memoka/memoka_body.dart';
import 'package:memoka/memoka/memoka_cover.dart';

import 'data_manager.dart';

class MemokaHome extends StatelessWidget {
  const MemokaHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var memokaData = DataManager().excelData;
    return Center(
        child: GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: memokaData.tables.keys.length,
      itemBuilder: (context, index) {
        String table = memokaData.tables.keys.elementAt(index);
        return GestureDetector(
          child:
              Hero(tag: 'memoka$index', child: MemokaCover(coverText: table)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Scaffold(
                          body: MemokaBody(
                        excelTable: table,
                      ))),
            );
          },
        );
      },
    ));
  }
}

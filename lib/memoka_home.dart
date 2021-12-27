import 'package:flutter/material.dart';
import 'package:memoka/memoka/memoka_body.dart';
import 'package:memoka/memoka/memoka_cover.dart';

import 'data_manager.dart';

class MemokaHome extends StatelessWidget {
  const MemokaHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var memokaData = DataManager().memokaGroupList;
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: memokaData.memokaGroups.length,
      itemBuilder: (context, index) {
        String cover = memokaData.memokaGroups[index].memokaCover;
        return GestureDetector(
          child:
              Hero(tag: 'memoka$index', child: MemokaCover(coverText: cover)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Scaffold(
                          body: MemokaBody(
                        memokaGroup: memokaData.memokaGroups[index],
                      ))),
            );
          },
        );
      },
    );
  }
}

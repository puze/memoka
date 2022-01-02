import 'package:flutter/material.dart';
import 'package:memoka/memoka/memoka_cover.dart';

import 'data_manager.dart';

class MemokaHome extends StatefulWidget {
  const MemokaHome({Key? key}) : super(key: key);

  @override
  State<MemokaHome> createState() => MemokaHomeState();
}

class MemokaHomeState extends State<MemokaHome> {
  @override
  void initState() {
    super.initState();
  }

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
        return MemokaCover(
          key: GlobalKey(),
          coverText: cover,
          memokaGroup: memokaData.memokaGroups[index],
          onLognPressCallback: clearRemoveButton,
          removeMemokaCallback: removeMemoka,
        );
      },
    );
  }

  MemokaCoverState? previousMemokaState;

  void clearRemoveButton(MemokaCoverState? memokaCoverState) {
    if (previousMemokaState != null) {
      previousMemokaState!.listenerOutSideTap();
    }
    previousMemokaState = memokaCoverState;
  }

  void removeMemoka() {
    setState(() {
      previousMemokaState = null;
    });
  }
}

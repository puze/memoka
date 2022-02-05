import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(explicitToJson: true)
class MemokaGroupList {
  late List<MemokaGroup> memokaGroups;
  late String coin;
  late String welcome;
  late String addMemokaAdRemove;
  late String tutorial;

  MemokaGroupList(
      {required this.memokaGroups,
      required this.coin,
      required this.welcome,
      required this.addMemokaAdRemove,
      required this.tutorial});

  MemokaGroupList.fromJson(Map<String, dynamic> json) {
    coin = json['coin'] ?? '';
    welcome = json['welcome'] ?? '';
    addMemokaAdRemove = json['add_memoka_ad_remove'] ?? '';
    tutorial = json['tutorial'] ?? '';
    if (json['memoka_group'] != null) {
      memokaGroups = [];
      json['memoka_group'].forEach((v) {
        memokaGroups.add(MemokaGroup.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['coin'] = coin;
    data['welcome'] = welcome;
    data['add_memoka_ad_remove'] = addMemokaAdRemove;
    data['tutorial'] = tutorial;
    data['memoka_group'] = memokaGroups.map((v) => v.toJson()).toList();
    return data;
  }
}

@JsonSerializable(explicitToJson: true)
class MemokaGroup {
  late String memokaCover;
  late String lastPage;
  late List<MemokaData> memokaData;
  late List<MemokaData> secondaryMemokaData;

  MemokaGroup(
      {required this.memokaCover,
      required this.memokaData,
      required this.lastPage,
      required this.secondaryMemokaData});

  MemokaGroup.fromJson(Map<String, dynamic> json) {
    memokaCover = json['memoka_cover'];
    lastPage = json['last_page'];
    if (json['memoka_data'] != null) {
      memokaData = <MemokaData>[];
      json['memoka_data'].forEach((v) {
        memokaData.add(MemokaData.fromJson(v));
      });
    }
    if (json['secondary_memoka_data'] != null) {
      secondaryMemokaData = <MemokaData>[];
      json['secondary_memoka_data'].forEach((v) {
        secondaryMemokaData.add(MemokaData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['memoka_cover'] = memokaCover;
    data['last_page'] = lastPage;
    data['memoka_data'] = memokaData.map((v) => v.toJson()).toList();
    data['secondary_memoka_data'] =
        secondaryMemokaData.map((v) => v.toJson()).toList();
    return data;
  }
}

@JsonSerializable(explicitToJson: true)
class MemokaData {
  late String front;
  late String back;
  late int index;

  MemokaData({required this.front, required this.back, required this.index});

  MemokaData.fromJson(Map<String, dynamic> json) {
    front = json['front'];
    back = json['back'];
    index = json['index'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['front'] = front;
    data['back'] = back;
    data['index'] = index;
    return data;
  }
}

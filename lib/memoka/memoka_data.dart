import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(explicitToJson: true)
class MemokaGroupList {
  late List<MemokaGroup> memokaGroups;

  MemokaGroupList({required this.memokaGroups});

  MemokaGroupList.fromJson(Map<String, dynamic> json) {
    if (json['memoka_group'] != null) {
      memokaGroups = [];
      json['memoka_group'].forEach((v) {
        memokaGroups.add(MemokaGroup.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['memoka_group'] = memokaGroups.map((v) => v.toJson()).toList();
    return data;
  }
}

@JsonSerializable(explicitToJson: true)
class MemokaGroup {
  late String memokaCover;
  late List<MemokaData> memokaData;

  MemokaGroup({required this.memokaCover, required this.memokaData});

  MemokaGroup.fromJson(Map<String, dynamic> json) {
    memokaCover = json['memoka_cover'];
    if (json['memoka_data'] != null) {
      memokaData = <MemokaData>[];
      json['memoka_data'].forEach((v) {
        memokaData.add(MemokaData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['memoka_cover'] = memokaCover;
    data['memoka_data'] = memokaData.map((v) => v.toJson()).toList();
    return data;
  }
}

@JsonSerializable(explicitToJson: true)
class MemokaData {
  late String front;
  late String back;

  MemokaData({required this.front, required this.back});

  MemokaData.fromJson(Map<String, dynamic> json) {
    front = json['front'];
    back = json['back'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['front'] = front;
    data['back'] = back;
    return data;
  }
}

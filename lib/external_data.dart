import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

class ExternalData extends StatefulWidget {
  const ExternalData({Key? key}) : super(key: key);

  @override
  State<ExternalData> createState() => _ExternalDataState();
}

class _ExternalDataState extends State<ExternalData> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  bool _isBusy = false;
  File? _currentFile;
  String? _pickedFilePath;

  Future<void> _pickFile() async {
    String? result;
    try {
      setState(() {
        _isBusy = true;
        _currentFile = null;
      });
      const OpenFileDialogParams params = OpenFileDialogParams(
          dialogType: OpenFileDialogType.document,
          sourceType: SourceType.photoLibrary,
          fileExtensionsFilter: ['xlsx']); // 확장자 필터
      result = await FlutterFileDialog.pickFile(params: params);
      print(result);
    } on PlatformException catch (e) {
      print(e);
    } finally {
      setState(() {
        _pickedFilePath = result;
        if (result != null) {
          _currentFile = File(result);
        } else {
          _currentFile = null;
        }
        _isBusy = false;
      });
    }
  }
}

// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert' show utf8;
import 'dart:async';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

enum BuildTreeTypeEnum {
  bottomUp,
  oneByOne,
}

String buildTreeTypeString(BuildTreeTypeEnum buildTreeType) {
  switch (buildTreeType) {
    case BuildTreeTypeEnum.bottomUp:
      return "Bottom Up";
    default:
      return "One By One";
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const String _title = 'B+ Tree visualization';

  // states
  BuildTreeTypeEnum choosedBuildTreeType = BuildTreeTypeEnum.bottomUp;

  // private method
  void setBuildTreeType(BuildTreeTypeEnum? buildTreeTypeEnum) {
    setState(() {
      choosedBuildTreeType = buildTreeTypeEnum!;
    });
  }

  void userChooseFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String path = result.files.single.path!;
      if (Platform.isMacOS) {
        path = path.substring(21);
      }
      File file = File(path);
      String data = await file.readAsString();
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(_title),
        ),
        body: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    // left container
                    width: 300.0,
                    height: double.infinity,
                    color: Colors.orange[200],
                    child: Column(
                      children: [
                        const Text("Choose Build Tree Method:"),
                        DropdownButton(
                          value: choosedBuildTreeType,
                          items: BuildTreeTypeEnum.values
                              .map<DropdownMenuItem<BuildTreeTypeEnum>>((e) =>
                                  DropdownMenuItem<BuildTreeTypeEnum>(
                                      value: e,
                                      child: Text(buildTreeTypeString(e))))
                              .toList(),
                          onChanged: setBuildTreeType,
                          icon: const Icon(Icons.arrow_downward),
                          elevation: 16,
                          style: const TextStyle(color: Colors.deepPurple),
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 20)),
                          onPressed: userChooseFile,
                          child: const Text('Enabled'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.orange[50],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

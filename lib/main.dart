// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import './bTree.dart';

void main() {
  BTree bTree = BTree(3);
  bTree.inSert(5);
  bTree.inSert(15);
  bTree.inSert(25);
  bTree.inSert(35);
  bTree.inSert(45);
  runApp(const MyApp());
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
  int maxDegree = 3;
  List<int> values = [];
  BTree? bTree;

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
      String dataStr = (await file.readAsString());
      List<int> data =
          dataStr.split(" ").map<int>((e) => int.parse(e)).toList();

      // action of after choose file
      BuildBTree(data, choosedBuildTreeType);
      setState(() {
        values = data;
      });
    } else {
      // User canceled the picker
    }
  }

  void BuildBTree(List<int> values, BuildTreeTypeEnum buildTreeType) {
    BTree bTree = BTree(maxDegree);
    for (int v in values) {
      bTree.inSert(v);
    }

    setState(() {
      this.bTree = bTree;
    });
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
                        const Text("Choose Max. Degree:"),
                        DropdownButton(
                          value: maxDegree,
                          items: [3, 4, 5, 6, 7]
                              .map<DropdownMenuItem<int>>((e) =>
                                  DropdownMenuItem<int>(
                                      value: e, child: Text('${e}')))
                              .toList(),
                          onChanged: (int? e) {
                            setState(() {
                              maxDegree = e!;
                            });
                          },
                          icon: const Icon(Icons.arrow_downward),
                          elevation: 16,
                          style: const TextStyle(color: Colors.deepPurple),
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
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
                          child: const Text('Choose File'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.orange[100],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 40),
                      child: Container(
                        color: Colors.brown[200],
                        child: (bTree == null)
                            ? Container()
                            : CustomPaint(
                                size: const Size(
                                    double.infinity, double.infinity),
                                painter: BTreePainter(bTree!),
                              ),
                      ),
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

class Box {
  // SETTING
  final boxLinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  final textStyle = TextStyle(
    color: Colors.black,
    fontSize: 20,
  );

  String content;
  TextPainter? textPainter;
  Size? size;
  final boxPadding = 5.0;

  Box(this.content, Size cSize) {
    final textSpan = TextSpan(
      text: content,
      style: textStyle,
    );
    textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter?.layout(
      minWidth: 0,
      maxWidth: double.infinity,
    );
    size = Size(textPainter!.width + 2 * boxPadding,
        textPainter!.height + 2 * boxPadding);
  }
}

class BTreePainter extends CustomPainter {
  // SETTING
  final boxLinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  final textStyle = TextStyle(
    color: Colors.black,
    fontSize: 20,
  );
  final boxPadding = 5.0;
  final levelDist = 70.0;
  final topMargin = 50.0;
  final sideMargin = 20.0;

  // state
  BTree bTree;

  BTreePainter(this.bTree);

  @override
  void paint(Canvas canvas, Size size) {
    // draw b tree
    List<List<Node>> levels = bTree.getLevel();
    List<List<Box>> levelBoxes = bTree
        .getLevel()
        .map<List<Box>>(
            (e) => e.map<Box>((e) => Box(e.valueStr(), size)).toList())
        .toList();
    // draw bottom first
    // 1. get bottom level total width
    double buttomWidth = -sideMargin;
    int levelCnt = levelBoxes.length;
    for (Box box in levelBoxes[levelCnt - 1]) {
      buttomWidth += box.size!.width + sideMargin;
    }
    // 2. draw bottom level
    double xOff = size.width / 2 - buttomWidth / 2;
    for (int i = 0; i < levelBoxes[levelCnt - 1].length; i++) {
      double preBoxWidth =
          (i != 0) ? levelBoxes[levelCnt - 1][i - 1].size!.width : 0;
      Box box = levelBoxes[levelCnt - 1][i];
      xOff += box.size!.width / 2;
      drawBoxText(box.content,
          Offset(xOff, topMargin + levelDist * (levelCnt - 1)), canvas, size);
      xOff += box.size!.width / 2 + sideMargin;
    }
    // 3. draw by buttom up
    for (int i = levelCnt - 2; i >= 0; i--) {}
  }

  @override
  bool shouldRepaint(BTreePainter oldDelegate) => false;

  Size drawBoxText(String t, Offset offset, Canvas canvas, Size cSize) {
    final textSpan = TextSpan(
      text: t,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: cSize.width,
    );
    double x = offset.dx, y = offset.dy;
    x -= textPainter.width / 2;
    y -= textPainter.height / 2;

    textPainter.paint(canvas, Offset(x, y));
    x -= boxPadding / 2;
    y -= boxPadding / 2;
    canvas.drawRect(
        Offset(x, y) &
            Size(textPainter.width + boxPadding,
                textPainter.height + boxPadding),
        boxLinePaint);

    return Size((textPainter.width + boxPadding) / 2.0,
        (textPainter.height + boxPadding) / 2.0);
  }
}

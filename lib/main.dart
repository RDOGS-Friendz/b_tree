// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import './bTree.dart';

void main() {
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
  // Setting
  static const String _title = 'B+ Tree visualization';
  ScrollController _scrollController = ScrollController();

  // states
  BuildTreeTypeEnum choosedBuildTreeType = BuildTreeTypeEnum.bottomUp;
  int maxDegree = 3;
  List<int> values = [];
  BTree? bTree;
  double treeButtomWidth = 2000.0;

  // private method
  void setBuildTreeType(BuildTreeTypeEnum? buildTreeTypeEnum) {
    buildBTree(values, buildTreeTypeEnum!);
    setState(() {
      choosedBuildTreeType = buildTreeTypeEnum;
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
      buildBTree(data, choosedBuildTreeType);
      setState(() {
        values = data;
      });
    } else {
      // User canceled the picker
    }
  }

  void buildBTree(List<int> values, BuildTreeTypeEnum buildTreeType) {
    if (values.isEmpty) {
      this.bTree = null;
      return;
    }
    BTree bTree = BTree(maxDegree);
    switch (buildTreeType) {
      case BuildTreeTypeEnum.oneByOne:
        for (int v in values) {
          bTree.inSert(v);
        }
        break;
      case BuildTreeTypeEnum.bottomUp:
        bTree.bottomUp(values);
        break;
    }

    // draw b tree
    List<List<Node>> levels = bTree.getLevel();
    // draw bottom first
    // 1. get bottom level total width
    treeButtomWidth = -20.0;
    int levelCnt = levels.length;
    for (Node node in levels[levelCnt - 1]) {
      treeButtomWidth += node.box!.size!.width + 20.0;
    }

    setState(() {
      this.bTree = bTree;
    });
  }

  @override
  Widget build(BuildContext context) {
    _scrollController.animateTo(
        (_scrollController.position.maxScrollExtent +
                _scrollController.position.minScrollExtent) /
            2,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease);
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
                        Container(
                            padding: const EdgeInsets.fromLTRB(30, 20, 20, 20),
                            child: Row(
                              children: [
                                const Text(
                                  "Choose Max. Degree:",
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 10.0),
                                  child: DropdownButton(
                                    value: maxDegree,
                                    items: [3, 4, 5, 6, 7]
                                        .map<DropdownMenuItem<int>>((e) =>
                                            DropdownMenuItem<int>(
                                                value: e, child: Text('${e}')))
                                        .toList(),
                                    onChanged: (int? e) {
                                      setState(() {
                                        maxDegree = e!;
                                        buildBTree(
                                            values, choosedBuildTreeType);
                                      });
                                    },
                                    icon: const Icon(Icons.arrow_downward),
                                    elevation: 16,
                                    style: const TextStyle(
                                        color: Colors.deepPurple),
                                    underline: Container(
                                      height: 2,
                                      color: Colors.deepPurpleAccent,
                                    ),
                                  ),
                                )
                              ],
                            )),
                        Container(
                          padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                          alignment: Alignment.topLeft,
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.topLeft,
                                child: const Text(
                                  "Choose Build Tree Method:",
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                alignment: Alignment.topLeft,
                                child: DropdownButton(
                                  value: choosedBuildTreeType,
                                  items: BuildTreeTypeEnum.values
                                      .map<DropdownMenuItem<BuildTreeTypeEnum>>(
                                          (e) => DropdownMenuItem<
                                                  BuildTreeTypeEnum>(
                                              value: e,
                                              child:
                                                  Text(buildTreeTypeString(e))))
                                      .toList(),
                                  onChanged: setBuildTreeType,
                                  icon: const Icon(Icons.arrow_downward),
                                  elevation: 16,
                                  style:
                                      const TextStyle(color: Colors.deepPurple),
                                  underline: Container(
                                    height: 2,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                textStyle: const TextStyle(fontSize: 20)),
                            onPressed: userChooseFile,
                            child: const Text('Choose File'),
                          ),
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
                            : Container(
                                child: Center(
                                  child: SingleChildScrollView(
                                    controller: _scrollController,
                                    scrollDirection: Axis.horizontal,
                                    child: CustomPaint(
                                      size: Size(treeButtomWidth + 100,
                                          treeButtomWidth + 100),
                                      painter: BTreePainter(bTree!),
                                    ),
                                  ),
                                ),
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

class BTreePainter extends CustomPainter {
  // SETTING
  final levelDist = 70.0;
  final topMargin = 50.0;
  final sideMargin = 20.0;
  final connectionlinePaint = Paint()
    ..color = Colors.black
    ..strokeWidth = 3.0;

  // state
  BTree bTree;
  double treeButtomWidth = 2000.0;

  BTreePainter(this.bTree);

  @override
  void paint(Canvas canvas, Size size) {
    // draw b tree
    List<List<Node>> levels = bTree.getLevel();
    // draw bottom first
    // 1. get bottom level total width
    treeButtomWidth = -sideMargin;
    int levelCnt = levels.length;
    for (Node node in levels[levelCnt - 1]) {
      treeButtomWidth += node.box!.size!.width + sideMargin;
    }
    // 2. draw bottom level
    double xOff = size.width / 2 - treeButtomWidth / 2;
    for (int i = 0; i < levels[levelCnt - 1].length; i++) {
      double preBoxWidth =
          (i != 0) ? levels[levelCnt - 1][i - 1].box!.size!.width : 0;
      Box box = levels[levelCnt - 1][i].box!;
      xOff += box.size!.width / 2;
      box.offset = Offset(xOff, topMargin + levelDist * (levelCnt - 1));
      drawBoxText(box, canvas, size);
      xOff += box.size!.width / 2 + sideMargin;
    }
    // 3. draw by buttom up
    for (int i = levelCnt - 2; i >= 0; i--) {
      // for each level
      List<Node> thisLevel = levels[i];
      double yOffset = topMargin + levelDist * i;
      // for each node
      for (int i = 0; i < thisLevel.length; i++) {
        // draw node box
        Node thisNode = thisLevel[i];
        Node? firstChild = thisNode.keys[0];
        Node? lastChild = thisNode.keys[thisNode.keys.length - 1];
        double xOffset =
            (firstChild!.box!.offset!.dx + lastChild!.box!.offset!.dx) / 2;
        thisNode.box?.offset = Offset(xOffset, yOffset);
        drawBoxText(thisNode.box!, canvas, size);
        // draw connection line to child
        drawConnectionLine(thisNode, canvas);
      }
    }
  }

  @override
  bool shouldRepaint(BTreePainter oldDelegate) => true;

  Size drawBoxText(Box box, Canvas canvas, Size cSize) {
    final textSpan = TextSpan(
      text: box.content,
      style: box.textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: cSize.width,
    );
    Offset offset = box.offset!;
    double x = offset.dx, y = offset.dy;
    x -= textPainter.width / 2;
    y -= textPainter.height / 2;
    Offset textOffset = Offset(x, y);
    x -= box.boxPadding / 2;
    y -= box.boxPadding / 2;
    Offset recOffset = Offset(x, y);

    canvas.drawRect(
        recOffset &
            Size(textPainter.width + box.boxPadding,
                textPainter.height + box.boxPadding),
        box.boxLinePaint);
    textPainter.paint(canvas, textOffset);

    return Size((textPainter.width + box.boxPadding) / 2.0,
        (textPainter.height + box.boxPadding) / 2.0);
  }

  void drawConnectionLine(Node node, Canvas canvas) {
    int childcnt = node.keys.length;
    List<Offset> parentPosList = [];
    List<Offset> childPosList = [];
    // set parent pos list
    double yOff = node.box!.offset!.dy + node.box!.size!.height / 2;
    if (childcnt >= 2) {
      for (int i = 0; i < childcnt; i++) {
        parentPosList.add(Offset(
            lerpDouble(
                node.box!.offset!.dx - node.box!.size!.width / 2,
                node.box!.offset!.dx + node.box!.size!.width / 2,
                i / (childcnt - 1.0))!,
            yOff));
      }
    } else {
      parentPosList.add(Offset(node.box!.offset!.dx, yOff));
    }

    // set child pos list
    for (int i = 0; i < childcnt; i++) {
      Node cNode = node.keys[i]!;
      childPosList.add(Offset(cNode.box!.offset!.dx,
          cNode.box!.offset!.dy - cNode.box!.size!.height / 2));
    }

    // draw
    for (int i = 0; i < childcnt; i++) {
      canvas.drawLine(parentPosList[i], childPosList[i], connectionlinePaint);
    }
  }
}

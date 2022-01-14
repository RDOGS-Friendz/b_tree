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

List<int> values = [];

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Setting
  static const String _title = 'B+ Tree visualization';
  ScrollController _scrollControllerH = ScrollController();
  Color primaryColor = Color(0xff198964);
  Color backgroundColor = Color(0xfff5f7f3);
  Color ColorsecondaryBackgroundColor = Color(0xffe9f6e2);
  Color ColortextColor = Color(0xff262730);

  // states
  BuildTreeTypeEnum choosedBuildTreeType = BuildTreeTypeEnum.bottomUp;
  int maxDegree = 3;
  BTree? bTree;
  double treeButtomWidth = 2000.0;
  int? insertNumber;

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
      String dataStr = (await file.readAsString()).trim();
      List<int> data1 = dataStr.split(" ").map<int>((e) {
        int? tmp = int.tryParse(e);
        if (tmp != null) {
          return tmp;
        } else {
          return -999;
        }
      }).toList();

      List<int> data = [];
      for (var i in data1) {
        if (i != -999) data.add(i);
      }

      // action of after choose file
      setState(() {
        values.clear();
        for (int i in data) {
          Add2ValueList(i);
        }
        buildBTree(data, choosedBuildTreeType);
      });
    } else {
      // User canceled the picker
    }
  }

  void Add2ValueList(int num) {
    if (values.contains(num) == false) values.add(num);
  }

  void buildBTree(List<int> values, BuildTreeTypeEnum buildTreeType) {
    if (values.isEmpty) {
      this.bTree = null;
      return;
    }
    List<int> tmp = [];
    for (int i in values) {
      if (tmp.contains(i) == false) tmp.add(i);
    }
    values = tmp;
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
    drawTree(bTree);
  }

  void drawTree(BTree bTree) {
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
    // if (_scrollControllerH.hasClients)
    //   _scrollControllerH.animateTo(
    //       (_scrollControllerH.position.maxScrollExtent +
    //               _scrollControllerH.position.minScrollExtent) /
    //           2,
    //       duration: Duration(milliseconds: 500),
    //       curve: Curves.ease);
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
          backgroundColor: backgroundColor,
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
                    color: ColorsecondaryBackgroundColor,
                    child: Column(
                      children: [
                        Container(
                            padding: const EdgeInsets.fromLTRB(30, 20, 20, 20),
                            child: Column(
                              children: [
                                LeftTitle(Icons.settings, "Tree Setting"),
                                Container(
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.only(top: 5),
                                  child: const Text(
                                    "Choose Max. Degree:",
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.fromLTRB(13, 0, 13, 4),
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                      color: backgroundColor,
                                      // border: Border.all(color: Colors.black),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                  child: DropdownButton(
                                    isExpanded: true,
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
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                        fontSize: 18),
                                    underline: Container(
                                      height: 2,
                                      // color: Colors.deepPurpleAccent,
                                      color: ColortextColor,
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
                                  margin: EdgeInsets.fromLTRB(0, 0, 26, 7),
                                  // width: 200,
                                  child: LeftTitle(
                                      Icons.file_download, "Bulk input")),
                              Container(
                                alignment: Alignment.topLeft,
                                child: const Text(
                                  "Choose Build Tree Method:",
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(13, 0, 13, 4),
                                margin: EdgeInsets.fromLTRB(0, 10, 25, 10),
                                decoration: BoxDecoration(
                                    color: backgroundColor,
                                    // border: Border.all(color: Colors.black),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                alignment: Alignment.topLeft,
                                child: DropdownButton(
                                  isExpanded: true,
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
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black),
                                  underline: Container(
                                    height: 2,
                                    color: ColortextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                          height: 43,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: primaryColor,
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 20)),
                            onPressed: userChooseFile,
                            child: const Text('Choose File'),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            // color: Colors.white,
                            child: Column(
                              children: [
                                Container(
                                    padding: EdgeInsets.fromLTRB(30, 20, 25, 0),
                                    child: LeftTitle(Icons.input, "UserInput")),
                                Row(
                                  children: [
                                    Container(
                                      alignment: Alignment.topLeft,
                                      margin: EdgeInsets.fromLTRB(25, 0, 0, 0),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 8),
                                      child: Container(
                                        width: 150,
                                        height: 38,
                                        child: TextField(
                                          textInputAction:
                                              TextInputAction.search,
                                          onSubmitted: (text) {
                                            insertNumber = int.tryParse(text);
                                            if (insertNumber != null) {
                                              if (bTree == null) {
                                                bTree = BTree(this.maxDegree);
                                              }
                                              Add2ValueList(insertNumber!);
                                              bTree!.inSert(insertNumber!);
                                              drawTree(bTree!);
                                            }
                                          },
                                          onChanged: (text) {
                                            insertNumber = int.tryParse(text);
                                          },
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.fromLTRB(
                                                10, 0, 0, 0),
                                            border: OutlineInputBorder(),
                                            hintText: 'Enter number...',
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(2, 0, 0, 0),
                                      height: 38,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: primaryColor,
                                            textStyle: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 20)),
                                        onPressed: () {
                                          if (insertNumber != null) {
                                            if (bTree == null) {
                                              bTree = BTree(this.maxDegree);
                                            }
                                            Add2ValueList(insertNumber!);
                                            bTree!.inSert(insertNumber!);
                                            drawTree(bTree!);
                                          }
                                        },
                                        child: const Text('Insert'),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 15),
                                  height: 40,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: Color(0xffBF3008),
                                        textStyle: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20)),
                                    onPressed: () {
                                      values = [];
                                      bTree = null;
                                      setState(() {
                                        buildBTree(
                                            values, choosedBuildTreeType);
                                      });
                                    },
                                    child: const Text('Clear'),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: backgroundColor,
                      // padding: const EdgeInsets.symmetric(
                      //     horizontal: 40, vertical: 40),
                      child: Container(
                        color: backgroundColor,
                        child: Container(
                          child: Center(
                            child: Scrollbar(
                              child: SingleChildScrollView(
                                // controller: _scrollControllerH,
                                primary: true,
                                scrollDirection: Axis.horizontal,
                                child: (bTree == null)
                                    ? Container(
                                        child: ManualPage(),
                                      )
                                    : CustomPaint(
                                        size: Size(treeButtomWidth + 100,
                                            treeButtomWidth + 100),
                                        painter: BTreePainter(bTree!),
                                      ),
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

class ManualPage extends StatelessWidget {
  const ManualPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(100),
        alignment: Alignment.center,
        child: Column(
          children: [
            Text(
              "Manual",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            Text("This app is a tool for visualize B+ tree",
                style: TextStyle(fontSize: 20)),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                width: 500,
                // color: Colors.white,
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Build tree method explain:",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600)),
                    Text(
                        "- One by One: insert list of integer in file to btree one by one\n- Bottom Up: first sort the integers in file then use the characteristic of sorted list to optimize build tree",
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w400)),
                    Text("\nBulk input file format:",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600)),
                    Text(
                        "     csv file contain integer seperate by white space",
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w400)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MyBullet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      decoration: new BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    );
  }
}

class LeftTitle extends StatelessWidget {
  LeftTitle(this.icon, this.title, {Key? key}) : super(key: key);
  IconData icon;
  String title;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              margin: EdgeInsets.only(right: 10),
              child: Icon(
                icon,
                size: 30,
              ),
            ),
            Container(
              child: Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
              ),
            ),
          ],
        ),
        Divider(
          thickness: 2,
        ),
      ],
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

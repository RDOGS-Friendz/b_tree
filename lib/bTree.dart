import 'package:flutter/material.dart';

enum BuildTreeTypeEnum {
  bottomUp,
  oneByOne,
}

class Node {
  int order;
  List<int> values = [];
  List<Node?> keys = [];
  Node? parent;
  bool checkLeaf = false;
  Box? box;

  Node(this.order);

  String valueStr() {
    return values.map<String>((e) => "$e").toList().join(" ");
  }

  void insertAtLeaf(int value) {
    if (values.isNotEmpty) {
      for (var i = 0; i < values.length; i++) {
        if (value == values[i]) {
          // ignore
          break;
        } else if (value < values[i]) {
          values.insert(i, value);
          break;
        } else if (i + 1 == values.length) {
          values.add(value);
          break;
        }
      }
    } else {
      values.add(value);
    }
  }
}

class BTree {
  Node? root;
  int order;

  BTree(this.order) {
    root = Node(order);
    root!.checkLeaf = true;
  }

  void bottomUp(List<int> values) {
    // sort
    values.sort();

    // buttom nodes
    List<Node> buttomNodes = [Node(order)];
    buttomNodes[0].checkLeaf = true;
    for (int i = 0; i < values.length; i++) {
      if (buttomNodes[buttomNodes.length - 1].values.length == order - 1) {
        // last node is full
        buttomNodes.add(Node(order));
        buttomNodes[buttomNodes.length - 1].checkLeaf = true;
        buttomNodes[buttomNodes.length - 1].values.add(values[i]);
      } else {
        buttomNodes[buttomNodes.length - 1].values.add(values[i]);
      }
    }

    while (true) {
      if (buttomNodes.length != 1) {
        // need a upper level
        List<Node> upperNodes = [Node(order)];
        // first child node
        upperNodes[0].keys.add(buttomNodes[0]);
        for (int i = 1; i < buttomNodes.length; i++) {
          if (upperNodes[upperNodes.length - 1].values.length == order - 1) {
            // last upper node is full
            upperNodes.add(Node(order));
            upperNodes[upperNodes.length - 1].keys.add(buttomNodes[i]);
            upperNodes[upperNodes.length - 1]
                .values
                .add(buttomNodes[i].values[0]);
          } else {
            upperNodes[upperNodes.length - 1].keys.add(buttomNodes[i]);
            upperNodes[upperNodes.length - 1]
                .values
                .add(buttomNodes[i].values[0]);
          }
        }
        buttomNodes = upperNodes;
      } else {
        // root level
        root = buttomNodes[0];
        break;
      }
    }
  }

  void inSert(int v) {
    var oldNode = search(v);
    oldNode.insertAtLeaf(v);

    if (oldNode.values.length == oldNode.order) {
      var node1 = Node(oldNode.order);
      node1.checkLeaf = true;
      node1.parent = oldNode.parent;
      int mid = (oldNode.order / 2.0).ceil() - 1;
      node1.values = oldNode.values.sublist(mid + 1);
      oldNode.values = oldNode.values.sublist(0, mid + 1);
      insertInParent(oldNode, node1.values[0], node1);
    }
  }

  Node search(int v) {
    Node? currentNode = root!;
    while (currentNode!.checkLeaf == false) {
      for (var i = 0; i < currentNode!.values.length; i++) {
        if (v == currentNode.values[i]) {
          currentNode = currentNode.keys[i + 1];
          break;
        } else if (v < currentNode.values[i]) {
          currentNode = currentNode.keys[i];
          break;
        } else if (i + 1 == currentNode.values.length) {
          currentNode = currentNode.keys[i + 1];
          break;
        }
      }
    }

    return currentNode;
  }

  void insertInParent(Node oldNode, int v, Node node1) {
    if (root == oldNode) {
      root = Node(oldNode.order);
      root?.values = [v];
      root?.keys = [oldNode, node1];
      oldNode.parent = root;
      node1.parent = root;
      return;
    }

    Node parentNode = oldNode.parent!;
    for (var i = 0; i < parentNode.keys.length; i++) {
      if (parentNode.keys[i] == oldNode) {
        parentNode.values.insert(i, v);
        parentNode.keys.insert(i + 1, node1);

        if (parentNode.keys.length > parentNode.order) {
          Node parentDash = Node(parentNode.order);
          parentDash.parent = parentNode.parent;
          int mid = (parentNode.order / 2.0).ceil() - 1;
          parentDash.values = parentNode.values.sublist(mid + 1);
          parentDash.keys = parentNode.keys.sublist(mid + 1);
          int valueDash = parentNode.values[mid];
          parentNode.values = parentNode.values.sublist(0, mid);
          parentNode.keys = parentNode.keys.sublist(0, mid + 1);
          for (var i = 0; i < parentNode.keys.length; i++) {
            parentNode.keys[i]?.parent = parentNode;
          }
          for (var i = 0; i < parentDash.keys.length; i++) {
            parentDash.keys[i]?.parent = parentDash;
          }
          insertInParent(parentNode, valueDash, parentDash);
        }
      }
    }
  }

  List<List<Node>> getLevel() {
    List<List<Node>> levels = [[]];
    Node node = root!;

    // get level cnt
    while (node.checkLeaf != true) {
      levels.add([]);
      node = node.keys[0]!;
    }

    node = root!;
    addLevels(node, 0, levels);

    return levels;
  }

  void addLevels(Node node, int level, List<List<Node>> levels) {
    node.box = Box(node.valueStr());
    levels[level].add(node);
    if (node.checkLeaf == false) {
      for (var k in node.keys) {
        addLevels(k!, level + 1, levels);
      }
    }
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
  Offset? offset;
  final boxPadding = 5.0;

  Box(
    this.content,
  ) {
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

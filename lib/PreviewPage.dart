import 'dart:io';
import 'package:flutter/material.dart';

class PreviewPage extends StatefulWidget {
  const PreviewPage(
      {super.key, required this.imagePath, required this.initialFilter});

  final String imagePath;
  final int initialFilter;

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  FixedExtentScrollController? fixedExtentScrollController;
  int currentIndex = 0;
  List<MaterialColor> myColors = Colors.primaries;

  void userClickedSpin(int jumpTo) {
    fixedExtentScrollController!.animateToItem(
      jumpTo,
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentIndex = widget.initialFilter;
    fixedExtentScrollController =
        FixedExtentScrollController(initialItem: currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

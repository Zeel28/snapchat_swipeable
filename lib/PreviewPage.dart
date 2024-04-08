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
    return Scaffold(
      body: SafeArea(
          child: Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                      Colors.primaries[currentIndex], BlendMode.hue),
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 100,
                  child: Stack(
                    children: [
                      Center(
                        child: RotatedBox(
                          quarterTurns: -1,
                          child: ListWheelScrollView.useDelegate(
                            diameterRatio: 7.5,
                            controller: fixedExtentScrollController,
                            renderChildrenOutsideViewport: true,
                            clipBehavior: Clip.none,
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: myColors.length,
                              builder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    userClickedSpin(index);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 400),
                                    height: index == currentIndex ? 50 : 40,
                                    width: index == currentIndex ? 50 : 40,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: myColors[index],
                                        border: Border.all(
                                          width: 2.5,
                                          color: Colors.black,
                                        )),
                                  ),
                                );
                              },
                            ),
                            itemExtent: 50,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (value) {
                              currentIndex = value;
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      // Center(
                      //   child: Container(
                      //     width: 80,
                      //     height: 80,
                      //     decoration: BoxDecoration(
                      //         shape: BoxShape.circle,
                      //         border: Border.all(width: 3, color: Colors.black)),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
              /* Container(
            decoration: BoxDecoration(
                color: Colors.primaries[widget.initialFilter].withOpacity(0.5)),
          )*/
            ],
          )),
    );
  }
}

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'PreviewPage.dart';

class SnapChatFilterScreen extends StatefulWidget {
  const SnapChatFilterScreen({super.key});

  @override
  State<SnapChatFilterScreen> createState() => _SnapChatFilterScreenState();
}

class _SnapChatFilterScreenState extends State<SnapChatFilterScreen>
    with WidgetsBindingObserver {
  double zoom = 0.0;
  FixedExtentScrollController fixedExtentScrollController =
  FixedExtentScrollController();
  int currentIndex = 0;
  List<MaterialColor> myColors = Colors.primaries;
   CameraController? _controller;
  List<CameraDescription>? _availableCameras;

  @override
  void initState() {
    super.initState();
    _getAvailableCameras();
  }

  Future<void> _getAvailableCameras() async {
    _availableCameras = await availableCameras();
    _initCamera(_availableCameras!.first);
  }

  Future<void> _initCamera(CameraDescription description) async {
    _controller = CameraController(description, ResolutionPreset.ultraHigh,
        enableAudio: true);
    try {
      await _controller!.initialize();
      setState(() {});
    } catch (e) {
      rethrow;
    }
  }

  void _toggleCameraLens() {
    final lensDirection = _controller!.description.lensDirection;
    CameraDescription newDescription;
    if (lensDirection == CameraLensDirection.front) {
      newDescription = _availableCameras!.firstWhere((description) =>
      description.lensDirection == CameraLensDirection.back);
    } else {
      newDescription = _availableCameras!.firstWhere((description) =>
      description.lensDirection == CameraLensDirection.front);
    }
    _initCamera(newDescription);
  }

  void userClickedSpin(int jumpTo) {
    fixedExtentScrollController.animateToItem(
      jumpTo,
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
    );
  }

  Future<XFile?> capturePhoto() async {
    final CameraController? cameraController = _controller;
    if (cameraController!.value.isTakingPicture) {
      return null;
    }
    try {
      await cameraController.setFlashMode(FlashMode.off); //optional
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  XFile? xFile;

  void _onTakePhotoPressed() async {
    xFile = await capturePhoto();
    if (xFile != null) {
      if (xFile!.path.isNotEmpty) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => PreviewPage(
          imagePath: xFile!.path,
          initialFilter: currentIndex,
        ),));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onScaleUpdate: (details) {
            zoom = details.scale;
            setState(() {
              _controller!.setZoomLevel(zoom);
            });
          },
          child: Stack(
            children: [
              if (_controller != null && _controller!.value.isInitialized) ...[
                SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                            myColors[currentIndex], BlendMode.hue),
                        child: CameraPreview(_controller!))),
              ],
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 40, right: 5),
                  child: IconButton(
                      onPressed: () {
                        _toggleCameraLens();
                      },
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 40,
                      )),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 120,
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
                                    // userClickedSpin(index);
                                  },
                                  child:
                                  Container(
                                    // duration: const Duration(milliseconds: 100),
                                    height: index == currentIndex ? 70 : 60,
                                    width: index == currentIndex ? 70 : 60,
                                    decoration:
                                    BoxDecoration(
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
                            itemExtent: 80,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (value) {
                              currentIndex = value;
                            },
                          ),
                        ),
                      ),
                      Center(
                        child: InkWell(
                          onTap: () {
                            _onTakePhotoPressed();
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                Border.all(width: 3, color: Colors.black)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    fixedExtentScrollController.dispose();
    super.dispose();
  }
}

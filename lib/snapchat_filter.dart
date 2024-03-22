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
  CameraController? _controller;
  bool _isCameraInitialized = false;
  late final List<CameraDescription> _cameras;
  FixedExtentScrollController fixedExtentScrollController =
      FixedExtentScrollController();
  int currentIndex = 0;
  List<MaterialColor> myColors = Colors.primaries;

  void userClickedSpin(int jumpTo) {
    fixedExtentScrollController.animateToItem(
      jumpTo,
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
    );
  }

  Future<void> initCamera() async {
    _cameras =
        await availableCameras(); // Initialize the camera with the first camera in the list
    await onNewCameraSelected(_cameras.first);
  }

  Future<void> onNewCameraSelected(CameraDescription description) async {
    final previousCameraController =
        _controller; // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      description,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    ); // Initialize controller

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      debugPrint('Error initializing camera: $e');
    } // Dispose the previous controller
    await previousCameraController
        ?.dispose(); // Replace with the new controller
    if (mounted) {
      setState(() {
        _controller = cameraController;
      });
    } // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    }); // Update the Boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = _controller!.value.isInitialized;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }

  Future<XFile?> capturePhoto() async {
    final CameraController? cameraController = _controller;
    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
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
    final navigator = Navigator.of(context);
    xFile = await capturePhoto();
    setState(() {});
    if (xFile != null) {
      if (xFile!.path.isNotEmpty) {
        navigator.push(
          MaterialPageRoute(
            builder: (context) => PreviewPage(
              imagePath: xFile!.path,
              initialFilter: currentIndex,
            ),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            if(_controller != null && _controller!.value.isInitialized)...[
            SizedBox(
                height: MediaQuery.of(context).size.height,
                child: ColorFiltered(
                    colorFilter:
                        ColorFilter.mode(myColors[currentIndex], BlendMode.hue),
                    child: CameraPreview(_controller!))),
            ],
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
                                  height: index == currentIndex ? 70 : 60,
                                  width: index == currentIndex ? 70 : 60,
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
                          itemExtent: 80,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (value) {
                            currentIndex = value;
                            setState(() {});
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
    );
  }
}

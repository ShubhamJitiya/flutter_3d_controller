import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

class TestAnimationViewer extends StatefulWidget {
  const TestAnimationViewer({super.key});

  @override
  State<TestAnimationViewer> createState() => _TestAnimationViewerState();
}

class _TestAnimationViewerState extends State<TestAnimationViewer> {
  Flutter3DController controller = Flutter3DController();
  List<String> availableAnimations = [];
  String? selectedAnimation;
  bool isModelLoaded = false;
  double animationSpeed = 1.0;
  bool isLooping = true;

  @override
  void initState() {
    super.initState();
    controller.onModelLoaded.addListener(() {
      if (controller.onModelLoaded.value) {
        setState(() {
          isModelLoaded = true;
        });
        _loadAnimations();
      }
    });
  }

  Future<void> _loadAnimations() async {
    try {
      final animations = await controller.getAvailableAnimations();
      setState(() {
        availableAnimations = animations;
        if (animations.isNotEmpty) {
          selectedAnimation = animations.first;
        }
      });
      debugPrint('Available animations: $animations');
    } catch (e) {
      debugPrint('Error loading animations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Flutter3DViewer(
          controller: controller,
          src: 'assets/test.fbx',
          activeGestureInterceptor: true,
          progressBarColor: Colors.deepPurple,
          enableTouch: true,
          onProgress: (progress) {
            debugPrint('Loading progress: ${(progress * 100).toInt()}%');
          },
          onLoad: (modelAddress) {
            debugPrint('Model loaded: $modelAddress');
            controller.setCameraOrbit(
                0, 75, 0.02); // Set to 0.2 for closer zoom
            controller.setCameraTarget(0, 0, 0);
            controller.playAnimation(loopCount: 0);
          },
          onError: (error) {
            debugPrint('Error loading model: $error');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $error'),
                backgroundColor: Colors.red,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Remove listeners if any
    controller.onModelLoaded.removeListener(() {});
    super.dispose();
  }
}

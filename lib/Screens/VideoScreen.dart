import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  final Widget nextScreen;

  const VideoScreen({required this.nextScreen});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('lib/assets/videos/LoopAnimation.mp4')
      ..initialize().then((_) {
        _controller.setLooping(false); // Play only once
        _controller.play();

        // Auto-navigate after the video finishes
        _controller.addListener(() {
          if (_controller.value.position >= _controller.value.duration) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => widget.nextScreen),
            );
          }
        });

        // No need to call setState since there's no loading UI
      });
  }

  @override
  void dispose() {
    _controller.removeListener(() {}); // Remove listener to avoid memory leaks
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white, // Add white background
        child: Center(
          child: AspectRatio(
            aspectRatio: _controller.value.isInitialized
                ? _controller.value.aspectRatio
                : 10 / 10, // Default aspect ratio while loading
            child: VideoPlayer(_controller),
          ),
        ),
      ),
    );
  }
}

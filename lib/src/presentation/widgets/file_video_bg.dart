import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:vs_story_designer/src/domain/providers/notifiers/control_provider.dart';

class FileVideoBg extends StatefulWidget {
  final String path;

  const FileVideoBg({super.key, required this.path});

  @override
  State<FileVideoBg> createState() => _FileVideoBgState();
}

class _FileVideoBgState extends State<FileVideoBg> {
  late final VideoPlayerController _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.file(File(widget.path));
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    await _videoController.initialize();

    final controlNotifier = context.read<ControlNotifier>();

    controlNotifier.videoDuration = _videoController.value.duration;

    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: true,
      looping: true,
      showControls: false,
      allowFullScreen: false,
      allowMuting: false,
      allowPlaybackSpeedChanging: false,
      aspectRatio: _videoController.value.aspectRatio == 0
          ? 16 / 9
          : _videoController.value.aspectRatio,
    );

    _videoController.setVolume(0);

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chewieController == null || !_videoController.value.isInitialized) {
      return const SizedBox(
        width: 120,
        height: 120,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return RepaintBoundary(
      child: Chewie(
        controller: _chewieController!,
      ),
    );
  }
}

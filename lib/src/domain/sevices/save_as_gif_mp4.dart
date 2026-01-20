import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vs_story_designer/src/domain/providers/FfmpegProvider.dart';
import 'package:vs_story_designer/src/domain/providers/notifiers/control_provider.dart';
import 'package:vs_story_designer/src/domain/providers/notifiers/rendering_notifier.dart';
import 'package:vs_story_designer/src/presentation/utils/constants/render_state.dart';

class WidgetRecorderController extends ChangeNotifier {
  WidgetRecorderController() : _containerKey = GlobalKey();

  /// RepaintBoundary key
  final GlobalKey _containerKey;

  /// Timer for FPS control
  Timer? _timer;

  /// Recording state
  bool _isRecording = false;

  /// Frame index
  int _frameIndex = 0;

  /// Frames directory
  late Directory _framesDir;

  /// FPS
  static const int fps = 30;

  GlobalKey get key => _containerKey;

  /// START RECORDING
  Future<void> start({
    required ControlNotifier controlNotifier,
    required RenderingNotifier renderingNotifier,
  }) async {
    if (_isRecording) return;

    _isRecording = true;
    _frameIndex = 0;

    controlNotifier.isRenderingWidget = true;
    renderingNotifier.renderState = RenderState.frames;

    final tempDir = await getTemporaryDirectory();
    _framesDir = Directory('${tempDir.path}/widget_frames');

    if (_framesDir.existsSync()) {
      _framesDir.deleteSync(recursive: true);
    }
    _framesDir.createSync(recursive: true);

    _timer = Timer.periodic(
      Duration(milliseconds: (1000 / fps).round()),
      (_) => _captureFrame(renderingNotifier),
    );
  }

  /// STOP RECORDING
  void stop({
    required ControlNotifier controlNotifier,
    required RenderingNotifier renderingNotifier,
  }) {
    _timer?.cancel();
    _isRecording = false;

    controlNotifier.isRenderingWidget = false;
    renderingNotifier.renderState = RenderState.preparing;
  }

  /// CAPTURE FRAME
  Future<void> _captureFrame(RenderingNotifier renderingNotifier) async {
    if (!_isRecording) return;

    final context = _containerKey.currentContext;
    if (context == null) return;

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) return;

    if (renderObject.debugNeedsPaint) return;

    try {
      final ui.Image image = await renderObject.toImage(pixelRatio: 2);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) return;

      final Uint8List bytes = byteData.buffer.asUint8List();

      final file = File(
        '${_framesDir.path}/${_frameIndex.toString().padLeft(5, '0')}.png',
      );

      await file.writeAsBytes(bytes);
      _frameIndex++;

      renderingNotifier.totalFrames = _frameIndex;
    } catch (e) {
      debugPrint('Frame capture error: $e');
    }
  }

  /// EXPORT VIDEO / GIF
  Future<Map<String, dynamic>> export({
    required RenderingNotifier renderingNotifier,
  }) async {
    renderingNotifier.renderState = RenderState.rendering;

    final response = await FfmpegProvider().mergeIntoVideo(
      renderType: renderingNotifier.renderType,
      inputDir: _framesDir.path,
      fps: fps,
    );

    return response;
  }
}

class ScreenRecorder extends StatelessWidget {
  const ScreenRecorder({
    super.key,
    required this.child,
    required this.controller,
  });

  final Widget child;
  final WidgetRecorderController controller;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: controller.key,
      child: child,
    );
  }
}

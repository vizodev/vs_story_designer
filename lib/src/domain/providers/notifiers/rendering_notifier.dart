import 'package:flutter/material.dart';
import 'package:vs_story_designer/src/presentation/utils/constants/render_state.dart';
import 'package:vs_story_designer/src/presentation/utils/constants/render_type.dart';

class RenderingNotifier extends ChangeNotifier {
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  RenderState _renderState = RenderState.none;
  RenderState get renderState => _renderState;
  set renderState(RenderState state) {
    _renderState = state;
    _safeNotify();
  }

  RenderType _renderType = RenderType.video;
  RenderType get renderType => _renderType;
  set renderType(RenderType type) {
    _renderType = type;
    _safeNotify();
  }

  int _recordingDuration = 3;
  int get recordingDuration => _recordingDuration;
  set recordingDuration(int time) {
    _recordingDuration = time;
    _safeNotify();
  }

  int _totalFrames = 0;
  int get totalFrames => _totalFrames;
  set totalFrames(int time) {
    _totalFrames = time;
    _safeNotify();
  }

  int _currentFrames = 0;
  int get currentFrames => _currentFrames;
  set currentFrames(int time) {
    _currentFrames = time;
    _safeNotify();
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vs_story_designer/src/domain/providers/notifiers/control_provider.dart';
import 'package:vs_story_designer/src/domain/providers/notifiers/rendering_notifier.dart';
import 'package:vs_story_designer/src/presentation/utils/constants/render_state.dart';

class RenderingIndicator extends StatelessWidget {
  const RenderingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ControlNotifier, RenderingNotifier>(
      builder: (_, __, rendering, ___) {
        if (rendering.renderState == RenderState.none) {
          return const SizedBox.shrink();
        }

        return Material(
          color: Colors.black38,
          child: Center(
            child: _IndicatorCard(rendering: rendering),
          ),
        );
      },
    );
  }
}

class _IndicatorCard extends StatelessWidget {
  final RenderingNotifier rendering;

  const _IndicatorCard({required this.rendering});

  @override
  Widget build(BuildContext context) {
    final hasProgress =
        rendering.totalFrames > 0 && rendering.currentFrames > 0;

    final progress =
        hasProgress ? rendering.currentFrames / rendering.totalFrames : null;

    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 46,
            height: 46,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              value: progress,
              color: const Color(0xFF2DB8BB),
              backgroundColor: Colors.white12,
            ),
          ),
          _Pulse(
            active: progress == null,
            color: const Color(0xFF2DB8BB),
          ),
        ],
      ),
    );
  }

  Color _stateColor(RenderState state) {
    switch (state) {
      case RenderState.preparing:
        return Colors.orangeAccent;
      case RenderState.frames:
        return Colors.redAccent;
      case RenderState.rendering:
        return Colors.purpleAccent;
      default:
        return Colors.white;
    }
  }
}

class _Pulse extends StatefulWidget {
  final bool active;
  final Color color;

  const _Pulse({required this.active, required this.color});

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return const SizedBox.shrink();

    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withOpacity(0.15),
        ),
      ),
    );
  }
}

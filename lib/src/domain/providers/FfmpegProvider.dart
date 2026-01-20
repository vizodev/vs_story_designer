// ignore_for_file: file_names

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vs_story_designer/src/presentation/utils/constants/render_type.dart';

class FfmpegProvider with ChangeNotifier {
  bool loading = false;
  bool isPlaying = false;

  Future<Map<String, dynamic>> mergeIntoVideo({
    required RenderType renderType,
    required String inputDir,
    required int fps,
  }) async {
    loading = true;
    notifyListeners();

    if (!await Permission.storage.request().isGranted) {
      loading = false;
      notifyListeners();

      if (await Permission.storage.isPermanentlyDenied) {
        openAppSettings();
      }

      return {
        'success': false,
        'msg': 'Missing storage permission.',
      };
    }

    final tempDir = await getTemporaryDirectory();

    final String outputPath = renderType == RenderType.gif
        ? '${tempDir.path}/widget_${DateTime.now().millisecondsSinceEpoch}.gif'
        : '${tempDir.path}/widget_${DateTime.now().millisecondsSinceEpoch}.mp4';

    final String inputPattern = '$inputDir/%05d.png';

    final String command = renderType == RenderType.gif
        ? '-framerate $fps -i $inputPattern '
            '-vf "scale=iw/2:ih/2:flags=lanczos" '
            '-loop 0 -y $outputPath'
        : '-framerate $fps -i $inputPattern '
            '-c:v libx264 -pix_fmt yuv420p '
            '-movflags +faststart -y $outputPath';

    /// ⚠️ NUNCA tipar como FFmpegSession
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    loading = false;
    notifyListeners();

    if (returnCode != null && returnCode.isValueSuccess()) {
      return {
        'success': true,
        'msg': 'Widget rendered successfully.',
        'outPath': outputPath,
      };
    }

    return {
      'success': false,
      'msg': 'FFmpeg failed.',
    };
  }
}

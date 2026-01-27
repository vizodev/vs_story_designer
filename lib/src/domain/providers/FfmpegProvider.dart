import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vs_story_designer/src/presentation/utils/constants/render_type.dart';

class FfmpegProvider with ChangeNotifier {
  bool loading = false;

  Future<Map<String, dynamic>> mergeIntoVideo({
    required RenderType renderType,
    required String inputDir,
    required int fps,
  }) async {
    loading = true;
    notifyListeners();

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
            '-c:v mpeg4 -q:v 5 -y $outputPath';

    debugPrint('FFmpeg command: $command');

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();
    final logs = await session.getAllLogsAsString();

    debugPrint('FFmpeg logs:\n$logs');

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

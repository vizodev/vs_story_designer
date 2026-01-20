import 'dart:io';

import 'package:flutter/material.dart';

class FileGifBg extends StatelessWidget {
  final String path;

  const FileGifBg({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(path),
      fit: BoxFit.contain,
      gaplessPlayback: true,
    );
  }
}

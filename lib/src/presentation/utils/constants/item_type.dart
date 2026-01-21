enum ItemType { image, text, video, gif }

enum MediaType {
  image(),
  video();

  const MediaType();
  bool get isVideo => this == MediaType.video;
  bool get isImage => this == MediaType.image;
  static MediaType fromPath(String value, {MediaType? orElse}) {
    if (value.isEmpty) {
      return orElse ?? (throw Exception('Media type is empty'));
    }
    if (containsVideoExtension(value)) {
      return MediaType.video;
    } else if (containsImageExtension(value)) {
      return MediaType.image;
    } else {
      return orElse ?? (throw Exception('Media type not found'));
    }
  }

  static MediaType? fromPathNullable(String? value, {MediaType? orElse}) {
    try {
      return fromPath(value ?? '', orElse: orElse);
    } catch (e) {
      return orElse;
    }
  }

  static String getFileExtension(String path) {
    final index = path.lastIndexOf('.');
    if (index == -1) return 'N/A';
    return path.substring(index);
  }
}

bool containsVideoExtension(String? path) {
  if (path == null || path.trim().isEmpty) return false;
  final lowerPath = path.toLowerCase();
  final extension = lowerPath.substring(lowerPath.lastIndexOf('.'));
  switch (extension) {
    case '.mp4':
    case '.mov':
    case '.MOV':
    case '.avi':
    case '.wmv':
    case '.flv':
    case '.webm':
    case '.mkv':
    case '.m4v':
    case '.gif':
      return true;
    default:
      return false;
  }
}

bool containsImageExtension(String? path) {
  if (path == null || path.trim().isEmpty) return false;
  final lowerPath = path.toLowerCase();
  final extension = lowerPath.substring(lowerPath.lastIndexOf('.'));
  switch (extension) {
    case '.jpg':
    case '.jpeg':
    case '.png':
    case '.gif':
    case '.webp':
    case '.bmp':
    case '.wbmp':
    case '.ico':
    case '.tif':
    case '.tiff':
    case '.pjpeg':
    case '.pjp':
      return true;
    default:
      return false;
  }
}

ItemType resolveItemTypeFromPath(String path) {
  final mediaType = MediaType.fromPath(path, orElse: MediaType.image);

  // Detecta GIF explicitamente
  final extension = path.toLowerCase();

  if (extension.endsWith('.gif')) {
    return ItemType.gif;
  }

  switch (mediaType) {
    case MediaType.image:
      return ItemType.image;
    case MediaType.video:
      return ItemType.video;
  }
}

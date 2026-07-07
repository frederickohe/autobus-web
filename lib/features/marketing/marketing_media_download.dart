import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Saves generated or uploaded marketing images and videos to the user's device.
class MarketingMediaDownloader {
  MarketingMediaDownloader._();

  static Future<bool> downloadPicture({
    Uint8List? bytes,
    String? localPath,
    String? mimeType,
    String? suggestedName,
  }) async {
    final data = await _resolveBytes(bytes: bytes, localPath: localPath);
    if (data == null || data.isEmpty) return false;

    final ext = _imageExtension(mimeType, suggestedName ?? localPath);
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final base = _sanitizeFileName(suggestedName) ?? 'marketing-image-$stamp';
    final fileName = base.contains('.') ? base : '$base.$ext';

    final path = await FilePicker.platform.saveFile(
      fileName: fileName,
      bytes: data,
      type: FileType.image,
    );
    return path != null || kIsWeb;
  }

  static Future<bool> downloadVideo({
    String? remoteUrl,
    String? localPath,
  }) async {
    Uint8List? data;

    if (!kIsWeb &&
        localPath != null &&
        localPath.isNotEmpty &&
        File(localPath).existsSync()) {
      data = await File(localPath).readAsBytes();
    } else {
      final url = remoteUrl?.trim();
      if (url == null || url.isEmpty) return false;

      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        if (!kIsWeb && File(url).existsSync()) {
          data = await File(url).readAsBytes();
        } else {
          return false;
        }
      } else {
        final response = await http.get(
          Uri.parse(url),
          headers: const {'User-Agent': 'Autobus/1.0'},
        );
        if (response.statusCode != 200) return false;
        data = response.bodyBytes;
      }
    }

    if (data.isEmpty) return false;

    final stamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'marketing-video-$stamp.mp4';

    final path = await FilePicker.platform.saveFile(
      fileName: fileName,
      bytes: data,
      type: FileType.video,
    );
    return path != null || kIsWeb;
  }

  static Future<Uint8List?> _resolveBytes({
    Uint8List? bytes,
    String? localPath,
  }) async {
    if (bytes != null && bytes.isNotEmpty) return bytes;
    if (!kIsWeb &&
        localPath != null &&
        localPath.isNotEmpty &&
        File(localPath).existsSync()) {
      return File(localPath).readAsBytes();
    }
    return null;
  }

  static String _imageExtension(String? mimeType, String? fileName) {
    switch (mimeType?.toLowerCase()) {
      case 'image/jpeg':
      case 'image/jpg':
        return 'jpg';
      case 'image/webp':
        return 'webp';
      case 'image/gif':
        return 'gif';
      case 'image/png':
        return 'png';
    }

    if (fileName != null) {
      final dot = fileName.lastIndexOf('.');
      if (dot > 0 && dot < fileName.length - 1) {
        return fileName.substring(dot + 1).toLowerCase();
      }
    }

    return 'png';
  }

  static String? _sanitizeFileName(String? name) {
    if (name == null || name.trim().isEmpty) return null;
    final base = name.split(RegExp(r'[\\/]')).last.trim();
    if (base.isEmpty) return null;
    return base.replaceAll(RegExp(r'[^\w.\-]+'), '_');
  }
}

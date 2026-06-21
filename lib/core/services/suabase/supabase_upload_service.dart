import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUploadService {
  static const int _preferredBytes = 500 * 1024;
  static const int _maximumBytes = 1024 * 1024;
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> uploadFile({
    required File file,
    required String bucket,
    required String folder,
    String? fileNamePrefix,
  }) async {
    File? compressedFile;
    try {
      if (!await file.exists()) {
        throw Exception('الملف غير موجود');
      }

      compressedFile = await _compressForUpload(file);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = fileNamePrefix == null
          ? '${timestamp}_${p.basenameWithoutExtension(file.path)}.webp'
          : '$fileNamePrefix-$timestamp.webp';

      final filePath = '$folder/$fileName';

      await _supabase.storage
          .from(bucket)
          .upload(
            filePath,
            compressedFile,
            fileOptions: const FileOptions(
              cacheControl: '31536000',
              upsert: false,
              contentType: 'image/webp',
            ),
          );

      final publicUrl = _supabase.storage.from(bucket).getPublicUrl(filePath);

      return publicUrl;
    } on StorageException {
      return null;
    } catch (_) {
      return null;
    } finally {
      if (compressedFile != null &&
          compressedFile.path != file.path &&
          await compressedFile.exists()) {
        await compressedFile.delete();
      }
    }
  }

  Future<File> _compressForUpload(File source) async {
    final tempDirectory = await getTemporaryDirectory();
    final baseName = p.basenameWithoutExtension(source.path);
    final attempts = <({int quality, int size})>[
      (quality: 82, size: 1920),
      (quality: 72, size: 1600),
      (quality: 62, size: 1280),
      (quality: 50, size: 1080),
      (quality: 40, size: 900),
    ];
    File? latest;

    for (var index = 0; index < attempts.length; index++) {
      final attempt = attempts[index];
      final targetPath = p.join(
        tempDirectory.path,
        '${baseName}_${DateTime.now().microsecondsSinceEpoch}_$index.webp',
      );
      final result = await FlutterImageCompress.compressAndGetFile(
        source.absolute.path,
        targetPath,
        format: CompressFormat.webp,
        quality: attempt.quality,
        minWidth: attempt.size,
        minHeight: attempt.size,
        keepExif: false,
      );
      if (result == null) continue;

      if (latest != null && await latest.exists()) await latest.delete();
      latest = File(result.path);
      final bytes = await latest.length();
      if (bytes <= _preferredBytes) return latest;
      if (bytes <= _maximumBytes && index >= 2) return latest;
    }

    if (latest == null || await latest.length() > _maximumBytes) {
      if (latest != null && await latest.exists()) await latest.delete();
      throw Exception('تعذر ضغط الصورة إلى أقل من 1MB');
    }
    return latest;
  }

  Future<bool> deleteFile({
    required String bucket,
    required String filePath,
  }) async {
    try {
      final response = await _supabase.storage.from(bucket).remove([filePath]);

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteUrl({required String url, required String bucket}) async {
    if (url.trim().isEmpty || !url.startsWith('http')) return true;
    final path = extractPathFromUrl(url, bucket);
    if (path.isEmpty) return true;
    return deleteFile(bucket: bucket, filePath: path);
  }

  Future<void> deleteUrls({
    required Iterable<String> urls,
    required String bucket,
  }) async {
    for (final url in urls.toSet()) {
      await deleteUrl(url: url, bucket: bucket);
    }
  }

  String extractPathFromUrl(String url, String bucket) {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;

    final index = segments.indexOf(bucket);

    if (index != -1 && index + 1 < segments.length) {
      return segments.sublist(index + 1).join('/');
    }

    return '';
  }
}

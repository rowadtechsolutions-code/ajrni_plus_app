import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUploadService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> uploadFile({
    required File file,
    required String bucket,
    required String folder,
    String? fileNamePrefix,
  }) async {
    try {
      if (!await file.exists()) {
        throw Exception('الملف غير موجود');
      }

      final extension = p.extension(file.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = fileNamePrefix == null
          ? '${timestamp}_${p.basename(file.path)}'
          : '$fileNamePrefix-$timestamp$extension';

      final filePath = '$folder/$fileName';

      await _supabase.storage
          .from(bucket)
          .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

      final publicUrl = _supabase.storage.from(bucket).getPublicUrl(filePath);

      return publicUrl;
    } on StorageException {
      return null;
    } catch (_) {
      return null;
    }
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

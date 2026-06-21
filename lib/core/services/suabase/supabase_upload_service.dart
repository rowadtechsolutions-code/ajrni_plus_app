import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUploadService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> uploadFile({
    required File file,
    required String bucket,
    required String folder,
  }) async {
    try {
      if (!await file.exists()) {
        throw Exception('الملف غير موجود');
      }

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}';

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

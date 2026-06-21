import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_tables.dart';
import '../../../core/services/suabase/supabase_upload_service.dart';
import '../../cars/models/car_model.dart';
import '../../offices/models/office_model.dart';

class DealerCarService {
  final SupabaseClient _client;
  final SupabaseUploadService _upload;

  DealerCarService({SupabaseClient? client, SupabaseUploadService? upload})
    : _client = client ?? Supabase.instance.client,
      _upload = upload ?? SupabaseUploadService();

  Future<List<CarModel>> getCars(String officeId) async {
    final response = await _client
        .from(SupabaseTables.cars)
        .select()
        .eq('office_id', officeId)
        .order('created_at', ascending: false);
    final officeRow = await _client
        .from(SupabaseTables.offices)
        .select()
        .eq('id', officeId)
        .maybeSingle();
    final office = officeRow == null ? null : OfficeModel.fromJson(officeRow);
    return response
        .map((row) => CarModel.fromJson(row, office: office))
        .toList();
  }

  Future<CarModel> save({
    CarModel? current,
    required String name,
    required String brand,
    required String model,
    required int year,
    required String color,
    required String fuel,
    required String transmission,
    required int seats,
    required String plateNumber,
    required String rentalType,
    required String status,
    required String price,
    required List<File> newImages,
    required List<String> existingImages,
  }) async {
    final officeId = _client.auth.currentUser!.id;
    final oldImages = current == null
        ? <String>{}
        : {
            current.image,
            ...current.images,
          }.where((url) => url.startsWith('http')).toSet();
    final uploaded = <String>[];

    try {
      for (final file in newImages.take(3 - existingImages.length)) {
        final url = await _upload.uploadFile(
          file: file,
          bucket: SupabaseTables.carsFolder,
          folder: officeId,
        );
        if (url == null) {
          throw const StorageException('Unable to upload car image');
        }
        uploaded.add(url);
      }

      final images = {...existingImages, ...uploaded}.take(3).toList();
      if (images.isEmpty) {
        throw const StorageException('At least one car image is required');
      }

      final payload = <String, dynamic>{
        'name': name.trim(),
        'brand': brand,
        'model': model,
        'year': year,
        'color': color.trim(),
        'fuel_type': fuel,
        'transmission': transmission,
        'seats': seats,
        'plate_number': plateNumber.trim().isEmpty ? null : plateNumber.trim(),
        'rental_type': rentalType,
        'status': status,
        'is_active': true,
        'office_id': officeId,
        'owner_id': officeId,
        'image': images.first,
        'images': images.skip(1).toList(),
        'price': price.trim(),
      };

      final Map<String, dynamic> row;
      if (current == null) {
        row = await _client
            .from(SupabaseTables.cars)
            .insert(payload)
            .select()
            .single();
      } else {
        row = await _client
            .from(SupabaseTables.cars)
            .update(payload)
            .eq('id', current.id)
            .select()
            .single();
      }

      await _upload.deleteUrls(
        urls: oldImages.difference(images.toSet()),
        bucket: SupabaseTables.carsFolder,
      );
      return CarModel.fromJson(row, office: current?.office);
    } catch (_) {
      await _upload.deleteUrls(
        urls: uploaded,
        bucket: SupabaseTables.carsFolder,
      );
      rethrow;
    }
  }

  Future<void> delete(CarModel car) async {
    await _client.from(SupabaseTables.cars).delete().eq('id', car.id);
    await _upload.deleteUrls(
      urls: {car.image, ...car.images},
      bucket: SupabaseTables.carsFolder,
    );
  }
}

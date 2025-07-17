import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:forsatech/constants/strings.dart';
import 'package:forsatech/dash_board/data/model/announcement_model.dart';
import 'package:forsatech/token_manager.dart';

class AnnouncementWebServices {
  final Dio _dio;

  AnnouncementWebServices()
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            receiveDataWhenStatusError: true,
            connectTimeout: const Duration(seconds: 60),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );

  Future<List<Announcement>> getAnnouncements() async {
    try {
      final response = await _dio.get(
        'create-ad',
        options: Options(headers: {
          "Accept": "application/json",
          'ngrok-skip-browser-warning': 'true'
        }),
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => Announcement.fromJson(e))
            .toList();
      }
    } catch (e) {
      print("❌ Get Announcements Error: $e");
    }
    return [];
  }

  Future<bool> createAnnouncement(Announcement announcement, File? imageFile,
      {Uint8List? imageBytes}) async {
    try {
      String? token = await TokenManager.getAccessToken();
      if (token == null) throw Exception("Unauthorized: Token is missing");

      // ✅ Upload image to Cloudinary first
      final imageUrl = await uploadImageToCloudinary(
        imageFile: imageFile,
        imageBytes: imageBytes,
      );

      final finalAnnouncement = Announcement(
        title: announcement.title,
        description: announcement.description,
        imageUrl: imageUrl, // 📎 Use Cloudinary image URL if available
      );

      final response = await _dio.post(
        'create-ad/',
        data: finalAnnouncement.toJson(),
        options: Options(
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
                      'ngrok-skip-browser-warning': 'true'

          },
        ),
      );

      print("📥 Server response: ${response.statusCode}");
      print("📥 Server data: ${response.data}");

      return response.statusCode == 201;
    } catch (e) {
      print("❌ Create Announcement Error: $e");
      return false;
    }
  }

  Future<String?> uploadImageToCloudinary(
      {File? imageFile, Uint8List? imageBytes}) async {
    const cloudName = 'doerwhivd';
    const uploadPreset = 'forsa-_unsigned_upload';
    const String cloudinaryUrl =
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

    try {
      FormData formData;

      if (imageFile != null) {
        formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(imageFile.path),
          'upload_preset': uploadPreset,
        });
      } else if (imageBytes != null) {
        formData = FormData.fromMap({
          'file': MultipartFile.fromBytes(imageBytes, filename: 'upload.jpg'),
          'upload_preset': uploadPreset,
        });
      } else {
        return null;
      }

      final response = await Dio().post(
        cloudinaryUrl,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200) {
        return response.data['secure_url'];
      } else {
        print('❌ Failed to upload image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Cloudinary Upload Error: $e');
      return null;
    }
  }
}

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:forsatech/constants/strings.dart';
import 'package:forsatech/dash_board/data/model/announcement_model.dart';
import 'package:forsatech/token_manager.dart';

class AnnouncementWebServices {
  final Dio _dio;

  AnnouncementWebServices()
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl, // ← غيّر هذا
            receiveDataWhenStatusError: true,
            connectTimeout: const Duration(seconds: 60),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );

  Future<List<Announcement>> getAnnouncements() async {
    try {
      final response = await _dio.get(
        'create-ad',
        options: Options(headers: {"Accept": "application/json"}),
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

  Future<bool> createAnnouncement(Announcement announcement) async {
    try {
      String? token = await TokenManager.getAccessToken();

      if (token == null) {
        debugPrint("No token found. Cannot proceed with request.");
        throw Exception("Unauthorized: Token is missing");
      }

      final response = await _dio.post(
        'create-ad/',
        data: jsonEncode(announcement.toJson()),
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token", // ← تمرير التوكن
          },
        ),
      );

      return response.statusCode == 201;
    } catch (e) {
      print("❌ Create Announcement Error: $e");
      return false;
    }
  }
}

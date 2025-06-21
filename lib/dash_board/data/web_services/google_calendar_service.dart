import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:forsatech/constants/strings.dart';
import 'package:forsatech/dash_board/data/model/model.dart';
import 'package:forsatech/token_manager.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

class GoogleCalendarService {
  Future<void> createGoogleCalendarEvent({
    required String title,
    String? description,
    required DateTime dateTime,
    required String recipientEmail,
    required GoogleSignInAccount googleUser,
  }) async {
    final auth = await googleUser.authentication;
    final accessToken = auth.accessToken;

    final event = {
      "summary": title,
      "description": description,
      "start": {
        "dateTime": dateTime.toUtc().toIso8601String(),
        "timeZone": "UTC"
      },
      "end": {
        "dateTime":
            dateTime.add(const Duration(hours: 1)).toUtc().toIso8601String(),
        "timeZone": "UTC"
      },
      "attendees": [
        {"email": recipientEmail}
      ]
    };

    final response = await http.post(
      Uri.parse(
          'https://www.googleapis.com/calendar/v3/calendars/primary/events?sendUpdates=all'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(event),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('حدث خطأ أثناء إنشاء الحدث: ${response.body}');
    }
  }
}

class JobAppointWebService {
  late Dio dio;

  JobAppointWebService() {
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      receiveDataWhenStatusError: true,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 30),
    );
    dio = Dio(options);
  }
  Future<List<JobAppont>> fromJsonJob() async {
    try {
      String? token = await TokenManager.getAccessToken();

      if (token == null) {
        throw Exception("Unauthorized: Token is missing");
      }

      final response = await dio.get(
        'opportunities/my-company/',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      print('*** Response ***');
      print('Status code: ${response.statusCode}');
      print('Status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is Map && response.data['opportunities'] != null) {
          List<dynamic> data = response.data['opportunities'];
          return data.map((e) => JobAppont.fromJsonJob(e)).toList();
        } else {
          throw Exception('Unexpected data format');
        }
      } else {
        throw Exception(
            'Failed to load job opportunities, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching job opportunities: $e');
    }
  }

  Future<JobAppont> fetchJobById(int jobId) async {
    try {
      final response = await dio.get(
        'opportunity-details/',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            "opportunity-id": jobId.toString(),
          },
        ),
      );

      print('*** Response ***');
      print('Status code: ${response.statusCode}');
      print('Status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        return JobAppont.fromJson(data);
      } else {
        throw Exception(
            'Failed to load opportunity, status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while fetching opportunity: $e');
      throw Exception('Error occurred while fetching opportunity: $e');
    }
  }
}

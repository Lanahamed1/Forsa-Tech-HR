import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:forsatech/constants/strings.dart';
import 'package:forsatech/dash_board/data/model/appointment_model.dart';
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
      throw Exception('error ${response.body}');
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
  Future<List<JobAppointment>> fromJsonJob() async {
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
            'ngrok-skip-browser-warning': 'true'
          },
        ),
      );
      // print('*** Response ***');
      // print('Status code: ${response.statusCode}');
      // print('Status code: ${response.statusCode}');
      // print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is Map && response.data['opportunities'] != null) {
          List<dynamic> data = response.data['opportunities'];
          return data.map((e) => JobAppointment.fromJsonJob(e)).toList();
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

  Future<JobAppointment> fetchJobById(int jobId) async {
    try {
      final response = await dio.get(
        'opportunity-details/',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            "opportunity-id": jobId.toString(),
            'ngrok-skip-browser-warning': 'true'
          },
        ),
      );

      // print('*** Response ***');
      // print('Status code: ${response.statusCode}');
      // print('Status code: ${response.statusCode}');
      // print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        return JobAppointment.fromJson(data);
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

class InterviewService {
  late Dio dio;

  InterviewService() {
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      receiveDataWhenStatusError: true,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 30),
    );
    dio = Dio(options);

    // اختياري: تسمح بفحص كل ردود السيرفر حتى لو خطأ (للتشخيص)
    dio.options.validateStatus = (status) => true;
  }

  Future<void> sendInterviewInfo({
    required String username,
    required int jobId,
    required DateTime interviewDateTime,
  }) async {
    final date = interviewDateTime.toIso8601String().split('T')[0];
    final time =
        interviewDateTime.toIso8601String().split('T')[1].substring(0, 8);

    final data = {
      'username': username,
      'opportunity_id': jobId,
      'date': date,
      'time': time,
    };
    print('Request body: $data');

    String? token = await TokenManager.getAccessToken();

    if (token == null) {
      debugPrint("No token found. Cannot proceed with request.");
      throw Exception("Unauthorized: Token is missing");
    }

    try {
      final response = await dio.post(
        'schedule-interview/',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'ngrok-skip-browser-warning': 'true'
          },
        ),
        data: data, // مرّر الـ Map مباشرة بدون json.encode
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('The data was successfully sent');
      } else {
        print('Response status code: ${response.statusCode}');
        print('Response data: ${response.data}');
        throw Exception('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Fail to send data: $e');
      rethrow;
    }
  }
}

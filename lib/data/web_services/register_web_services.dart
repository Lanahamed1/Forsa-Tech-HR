import 'package:dio/dio.dart';
import 'package:forsatech/constants/strings.dart';

class RegisterWebServices {
  late Dio dio;

  RegisterWebServices() {
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      receiveDataWhenStatusError: true,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 30),
    );
    dio = Dio(options);
  }

  Future<bool> logIn(String username, String password) async {
    try {
      Response response = await dio.post(
        'register',
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        return true;
      }
    } catch (error) {
      print(error.toString());
    }
    return false;
  }
}

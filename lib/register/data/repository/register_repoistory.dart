import 'package:forsatech/register/data/web_services/register_web_services.dart';

class RegisterRepository {
  final RegisterWebServices registerWebServices;

  RegisterRepository({required this.registerWebServices});

  Future<Map<String, dynamic>?> logIn(String username, String password) {
    return registerWebServices.logIn(username, password);
  }
}

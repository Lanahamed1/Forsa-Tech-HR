import 'package:forsatech/data/web_services/register_web_services.dart';

class RegisterRepository {
  final RegisterWebServices registerWebServices;

  RegisterRepository({required this.registerWebServices});

  Future<bool> logIn(String username, String password) {
    return registerWebServices.logIn(username, password);
  }
}

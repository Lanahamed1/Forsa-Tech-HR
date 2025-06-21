import 'package:bloc/bloc.dart';
import 'package:forsatech/register/business_logic/cubit/register_state.dart';
import 'package:forsatech/register/data/repository/register_repoistory.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterRepository registerRepository;

  RegisterCubit({required this.registerRepository}) : super(RegisterInitial());

  Future<void> logIn(String username, String password) async {
    emit(RegisterLoading());
    try {
      final response = await registerRepository.logIn(username, password);

      if (response != null && response['access'] != null) {
        final companyName = response['company_name'] ?? 'Unknown';
        final companyLogo = response['company_logo'] ?? '';

        emit(RegisterSuccess(
            companyName: companyName, companyLogo: companyLogo));
      } else {
        emit(RegisterFailure("Invalid credentials"));
      }
    } catch (e) {
      emit(RegisterFailure(e.toString()));
    }
  }
}

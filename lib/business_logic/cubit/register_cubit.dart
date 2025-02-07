import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:forsatech/data/repository/register_repoistory.dart';
part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterRepository registerRepository;

  RegisterCubit({required this.registerRepository}) : super(RegisterInitial());
  Future<void> logIn(String username, String password) async {
    emit(RegisterLoading());
    try {
      bool isSuccess = await registerRepository.logIn(username, password);
      if (isSuccess) {
        emit(RegisterSuccess());
      } else {
        emit(RegisterFailure("Invalid credentials"));
      }
    } catch (e) {
      emit(RegisterFailure(e.toString()));
    }
  }
}

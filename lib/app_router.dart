import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forsatech/business_logic/cubit/register_cubit.dart';
import 'package:forsatech/constants/strings.dart';
import 'package:forsatech/data/repository/register_repoistory.dart';
import 'package:forsatech/presentation/screens/register_screen.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case registerScreen:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => RegisterCubit(
              registerRepository: context.read<RegisterRepository>(),
            ),
            child: RegisterScreen(),
          ),
        );
    }
    return null;
  }
}


    //  case Routes.loginScreen:
    //     return MaterialPageRoute(
    //       builder: (_) => BlocProvider(
    //         create: (context) => getIt<LoginCubit>(),
    //         child: const LoginScreen(),
    //       ),
    //     );
    //   case Routes.signUpScreen:
    //     return MaterialPageRoute(
    //       builder: (_) => BlocProvider(
    //         create: (context) => getIt<SignupCubit>(),
    //         child: const SignupScreen(),
    //       ),
    //     );
    //   case Routes.homeScreen:
    //     return MaterialPageRoute(
    //       builder: (_) => BlocProvider(
    //         create: (context) => HomeCubit(getIt())..getSpecializations(),
    //         child: const HomeScreen(),
    //       ),
    //     );
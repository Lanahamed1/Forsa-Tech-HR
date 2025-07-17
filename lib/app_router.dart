import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forsatech/constants/strings.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_cubit.dart';
import 'package:forsatech/dash_board/data/repository/opportunity_repository.dart';
import 'package:forsatech/dash_board/presentation/screens/dash_board_screen.dart';
import 'package:forsatech/register/business_logic/cubit/register_cubit.dart';
import 'package:forsatech/register/presentation/screens/register_screen.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case registerScreen:
        return MaterialPageRoute(
          builder: (context) => RegisterScreen(),
        );

      case dashboardScreen:
        return MaterialPageRoute(
          builder: (context) {
            final registerCubit = BlocProvider.of<RegisterCubit>(context);
            final opportunityRepository =
                RepositoryProvider.of<OpportunityRepository>(context);

            return MultiBlocProvider(
              providers: [
                BlocProvider.value(value: registerCubit),
                BlocProvider(
                  create: (context) => OpportunityCubit(opportunityRepository),
                ),
              ],
              child: const DashboardScreen(),
            );
          },
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text("404 - Page not found"),
            ),
          ),
        );
    }
  }
}

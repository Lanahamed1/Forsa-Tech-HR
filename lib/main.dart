import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forsatech/app_router.dart';
import 'package:forsatech/business_logic/cubit/register_cubit.dart';
import 'package:forsatech/data/repository/register_repoistory.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:forsatech/data/web_services/register_web_services.dart'; 

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<RegisterRepository>(
          create: (_) => RegisterRepository(registerWebServices: RegisterWebServices()), 
        ),
        BlocProvider<RegisterCubit>(
          create: (context) => RegisterCubit(registerRepository: context.read<RegisterRepository>()),
        ),
      ],
      child: ForsaTachApp(appRouter: AppRouter()),
    ),
  );
}

class ForsaTachApp extends StatelessWidget {
  final AppRouter appRouter;

  const ForsaTachApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: appRouter.generateRoute,
    );
  }
}

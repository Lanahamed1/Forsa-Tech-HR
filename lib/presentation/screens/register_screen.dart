import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forsatech/business_logic/cubit/register_cubit.dart';
import 'package:forsatech/data/repository/register_repoistory.dart';
import 'package:forsatech/presentation/widgets/widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final Widgets widgets = Widgets();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(
          registerRepository:
              RepositoryProvider.of<RegisterRepository>(context)),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocListener<RegisterCubit, RegisterState>(
          listener: (context, state) {
            if (state is RegisterSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Login Successful')),
              );
            } else if (state is RegisterFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage)),
              );
            }
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Image.asset(
                          'assets/images/low-angle-view-skyscrapers (1).jpg',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            const Text(
                              'Welcome to Forsa-Tech',
                              style: TextStyle(
                                fontSize: 55,
                                color: Color.fromARGB(246, 0, 25, 150),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            widgets.buildDivider(600),
                            const SizedBox(height: 130),
                            const Text(
                              'Login as a human resource',
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.black,
                                  fontFamily: 'CustomFont'),
                            ),
                            const SizedBox(height: 20),
                            widgets.buildTextFormField(
                              controller: usernameController,
                              label: "E-mail",
                              hintText: "Enter your e-mail",
                              icon: Icons.email_outlined,
                              validator: (value) =>
                                  value!.isEmpty ? "The field is empty" : null,
                            ),
                            const SizedBox(height: 40),
                            widgets.buildTextFormField(
                              controller: passwordController,
                              label: "Password",
                              hintText: "Enter your password",
                              icon: Icons.visibility,
                              obscureText: true,
                              validator: (value) {
                                if (value!.isEmpty) return "The field is empty";
                                if (value.length < 8)
                                  return "Minimum length is 12 characters";
                                return null;
                              },
                            ),
                            const SizedBox(height: 40),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: const Text(
                                  "Forgot password?",
                                  style: TextStyle(
                                      color: Color.fromARGB(246, 0, 25, 150)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 75),
                           
                            BlocBuilder<RegisterCubit, RegisterState>(
                              builder: (context, state) {
                                if (state is RegisterLoading) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                return widgets.buildSignInButton(
                                  context,
                                  formKey,
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      context.read<RegisterCubit>().logIn(
                                            usernameController.text,
                                            passwordController.text,
                                          );
                                    }
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

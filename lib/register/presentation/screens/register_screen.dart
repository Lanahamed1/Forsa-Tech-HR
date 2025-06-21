import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forsatech/register/business_logic/cubit/register_cubit.dart';
import 'package:forsatech/register/business_logic/cubit/register_state.dart';
import 'package:forsatech/register/presentation/widgets/widgets.dart';

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
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login Successful')),
            );
            Navigator.pushReplacementNamed(context, '/dashboardScreen');
          } else if (state is RegisterFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            // For narrow screens (like mobile), stack the views vertically
            bool isMobile = constraints.maxWidth < 800;

            return isMobile
                ? SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: buildFormContent(context, isMobile),
                    ),
                  )
                : Row(
                    children: [
                      // Left side image (hidden in small screens)
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: Colors.grey[200],
                          child: Image.asset(
                            'assets/images/low-angle-view-skyscrapers (1).jpg',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                      // Right side form
                      Expanded(
                        flex: 1,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 32),
                          child: buildFormContent(context, isMobile),
                        ),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget buildFormContent(BuildContext context, bool isMobile) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: const Text(
              'Welcome to Forsa-Tech',
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 22),
          widgets.buildDivider(isMobile ? 100 : 600),
          const SizedBox(height: 40),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: const Text(
              'Login as a human resource',
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'CustomFont',
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 25),
          widgets.buildTextFormField(
            controller: usernameController,
            label: "Email",
            hintText: "Enter your Email",
            suffixIcon: Icon(Icons.email_outlined),
            validator: (value) => value!.isEmpty ? "The field is empty" : null,
          ),
          const SizedBox(height: 30),
          widgets.buildTextFormField(
            controller: passwordController,
            label: "Password",
            hintText: "Enter your password",
            obscureText: _obscurePassword,
            validator: (value) {
              if (value!.isEmpty) return "The field is empty";
              if (value.length < 8) return "Minimum length is 8 characters";
              return null;
            },
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),

          const SizedBox(height: 20),
          // Align(
          //   alignment: Alignment.centerRight,
          //   child: TextButton(
          //     onPressed: () {},
          //     child: ShaderMask(
          //       shaderCallback: (bounds) => const LinearGradient(
          //         colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
          //         begin: Alignment.topLeft,
          //         end: Alignment.bottomRight,
          //       ).createShader(bounds),
          //       child: const Text(
          //         "Forgot password?",
          //         style: TextStyle(color: Colors.white),
          //       ),
          //     ),
          //   ),
          // ),
          const SizedBox(height: 40),
          BlocBuilder<RegisterCubit, RegisterState>(
            builder: (context, state) {
              if (state is RegisterLoading) {
                return const Center(child: CircularProgressIndicator());
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
    );
  }
}

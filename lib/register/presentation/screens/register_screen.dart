// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forsatech/register/business_logic/cubit/register_cubit.dart';
import 'package:forsatech/register/business_logic/cubit/register_state.dart';
import 'package:forsatech/register/data/web_services/register_web_services.dart';
import 'package:forsatech/register/presentation/widgets/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          BlocListener<RegisterCubit, RegisterState>(
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
          Positioned(
              bottom: 16,
              right: 16,
              child: TextButton.icon(
                onPressed: () => _showContactDialog(context),
                icon: const Icon(Icons.contact_mail, color: Color(0xFF4F46E5)),
                label: Text(
                  "Contact Us",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Color(0xFF4F46E5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )),
        ],
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
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF4F46E5),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(40, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => widgets.showChangePasswordDialog(context),
                child: Text(
                  "Forgot Password?",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30), // لضبط المسافة قبل زر الدخول
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    final TextEditingController subjectController = TextEditingController();
    final TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        title: Center(
          child: Text(
            "Contact Us",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4F46E5),
            ),
          ),
        ),
        content: SizedBox(
          width: 350,
          height: 200,
          child: Column(
            children: [
              TextField(
                controller: subjectController,
                decoration: InputDecoration(
                  labelText: "Subject",
                  hintText: "I communicate with you from Enter comany name ",
                  labelStyle: GoogleFonts.poppins(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TextField(
                  controller: messageController,
                  maxLines: null,
                  expands: true,
                  decoration: InputDecoration(
                    labelText: "Message",
                    hintText: "Enter your problem! ",
                    labelStyle: GoogleFonts.poppins(),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color(0xFF4F46E5), width: 1.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(color: Colors.grey[700]),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await RegisterWebServices().sendContactMessage(
                subject: subjectController.text,
                message: messageController.text,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✅ Message sent successfully!")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              "Send",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

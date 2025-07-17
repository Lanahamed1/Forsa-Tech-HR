import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forsatech/dash_board/data/web_services/profile_web_servoces.dart';

class Widgets {
  Widget buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
        label: Container(
          margin: const EdgeInsets.symmetric(horizontal: 9),
          child: Text(
            label,
            style: const TextStyle(color: Colors.black),
          ),
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  Widget buildSignInButton(BuildContext context, GlobalKey<FormState> formKey,
      {required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(150),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3B82F6), // أزرق
            Color(0xFF9333EA), // بنفسجي
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(150),
          ),
          backgroundColor: Colors.transparent, // مهم لتطبيق التدرج
          shadowColor: Colors.transparent, // منع ظل الخلفية الافتراضي
        ),
        onPressed: () {
          if (formKey.currentState!.validate()) {
            onPressed();
          } else {
            const snackBar = SnackBar(
              content: Text("Form isn't valid!"),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        child: const Text(
          "Log in",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget buildDivider(double endIndent) {
    return Padding(
      padding: EdgeInsetsDirectional.only(end: endIndent),
      child: Container(
        height: 2,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF3B82F6), // أزرق
              Color(0xFF9333EA), // بنفسجي
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }

  void showChangePasswordDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    final emailController = TextEditingController();
    final otpController = TextEditingController();
    final newPasswordController = TextEditingController();

    bool isOTPSent = false;
    int secondsRemaining = 600; // 10 دقائق
    Timer? countdownTimer;

    void startCountdown(StateSetter setState) {
      countdownTimer?.cancel(); // أوقف مؤقت سابق إن وجد
      countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (secondsRemaining == 0) {
          timer.cancel();
        } else {
          setState(() {
            secondsRemaining--;
          });
        }
      });
    }

    String formatTime(int seconds) {
      final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
      final secs = (seconds % 60).toString().padLeft(2, '0');
      return "$minutes:$secs";
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text(
                "Change Password",
                style: TextStyle(color: Color(0xFF4F46E5)),
              ),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: "Email"),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your email";
                          }
                          final emailRegex =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$');
                          if (!emailRegex.hasMatch(value)) {
                            return "Invalid email format";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      if (isOTPSent) ...[
                        TextFormField(
                          controller: otpController,
                          decoration:
                              const InputDecoration(labelText: "OTP Code"),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter OTP";
                            }
                            if (value.length != 6) {
                              return "OTP must be 6 digits";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: newPasswordController,
                          obscureText: true,
                          decoration:
                              const InputDecoration(labelText: "New Password"),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter a new password";
                            }
                            if (value.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          secondsRemaining > 0
                              ? "OTP expires in ${formatTime(secondsRemaining)}"
                              : "OTP expired",
                          style: TextStyle(
                            color: secondsRemaining > 0
                                ? Colors.black54
                                : Colors.red,
                            fontSize: 13,
                          ),
                        ),
                        if (secondsRemaining == 0)
                          TextButton.icon(
                            onPressed: () async {
                              try {
                                await CompanyWebService()
                                    .requestPasswordResetOTP(
                                        emailController.text.trim());
                                setState(() {
                                  secondsRemaining = 600;
                                });
                                startCountdown(setState);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("OTP resent to your email")),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error: $e")),
                                );
                              }
                            },
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text("Resend OTP"),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    countdownTimer?.cancel();
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    final email = emailController.text.trim();
                    final otp = otpController.text.trim();
                    final newPassword = newPasswordController.text.trim();

                    try {
                      if (!isOTPSent) {
                        await CompanyWebService()
                            .requestPasswordResetOTP(email);
                        setState(() {
                          isOTPSent = true;
                          secondsRemaining = 600;
                        });
                        startCountdown(setState);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("OTP sent to your email")),
                        );
                      } else {
                        await CompanyWebService().confirmPasswordReset(
                          email: email,
                          otp: otp,
                          newPassword: newPassword,
                        );
                        countdownTimer?.cancel();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Password updated successfully")),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                      );
                    }
                  },
                  child: Text(isOTPSent ? "Confirm" : "Send"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

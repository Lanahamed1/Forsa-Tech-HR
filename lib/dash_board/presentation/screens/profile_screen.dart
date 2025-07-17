import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_cubit.dart';
import 'package:forsatech/dash_board/business_logic/cubit/dash_board_state.dart';
import 'package:forsatech/dash_board/data/web_services/profile_web_servoces.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:forsatech/dash_board/data/model/profile_model.dart';
import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:html' as html;

class CompanyProfileScreen extends StatelessWidget {
  final CompanyWebService webService = CompanyWebService();

  CompanyProfileScreen({super.key});

  Future<dynamic> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return null;

    if (kIsWeb) {
      final bytes = await pickedFile.readAsBytes();
      final blob = html.Blob([bytes]);
      final file = html.File([blob], pickedFile.name);
      return file;
    } else {
      return File(pickedFile.path);
    }
  }

  Future<String?> pickAndUploadImage(BuildContext context) async {
    final file = await pickImage();
    if (file != null) {
      try {
        final uploadedUrl = await webService.uploadImage(file);
        return uploadedUrl;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image')),
        );
      }
    }
    return null;
  }

  void _onChangeLogo(BuildContext context) async {
    final file = await pickImage();
    if (file != null) {
      try {
        final uploadedUrl = await webService.uploadImage(file);
        print("Uploaded logo URL: $uploadedUrl");
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.read<CompanyCubit>().loadCompanyProfile();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            "Company Profile",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: BlocBuilder<CompanyCubit, CompanyState>(
        builder: (context, state) {
          if (state is CompanyLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CompanyLoaded) {
            return _buildProfile(context, state.profile);
          } else if (state is CompanyError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: GoogleFonts.poppins(color: Colors.red, fontSize: 16),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProfile(BuildContext context, CompanyProfile company) {
    final logo = company.logoUrl.isNotEmpty
        ? NetworkImage(company.logoUrl)
        : const AssetImage('assets/images/default_logo.png') as ImageProvider;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            backgroundImage: logo,
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 6),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        company.name,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4F46E5),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF4F46E5)),
                      tooltip: "Edit Profile",
                      onPressed: () => _showEditDialog(context, company),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _labeledInfo(
                    "Location", Icons.location_on_outlined, company.address),
                const SizedBox(height: 16),
                _labeledInfo("Email", Icons.email_outlined, company.email),
                const SizedBox(height: 16),
                _labeledInfo(
                    "Website", Icons.language_outlined, company.website),
                const SizedBox(height: 28),
                Text(
                  "About Us",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4F46E5),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  company.description.isNotEmpty
                      ? company.description
                      : "No description available.",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showChangePasswordDialog(context),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets
                          .zero, 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      backgroundColor: Colors.transparent, 
                      shadowColor: Colors.black26,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_outline, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              "Change Password",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _labeledInfo(String label, IconData icon, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF4F46E5), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value.isNotEmpty ? value : "Not provided",
                style:
                    GoogleFonts.poppins(fontSize: 14.5, color: Colors.black87),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context, CompanyProfile company) {
    final aboutController = TextEditingController(text: company.description);
    String? newLogoUrl = company.logoUrl;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Center(
              child: Text(
                "Edit Company Info",
                style: TextStyle(color: Color(0xFF4F46E5)),
              ),
            ),
            content: SizedBox(
              width: 500,
              height: 400,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final uploadedUrl = await pickAndUploadImage(context);
                        if (uploadedUrl != null) {
                          setState(() {
                            newLogoUrl = uploadedUrl;
                          });
                        }
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: newLogoUrl != null &&
                                newLogoUrl!.isNotEmpty
                            ? NetworkImage(newLogoUrl!)
                            : const AssetImage('assets/images/default_logo.png')
                                as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () async {
                        final uploadedUrl = await pickAndUploadImage(context);
                        if (uploadedUrl != null) {
                          setState(() {
                            newLogoUrl = uploadedUrl;
                          });
                        }
                      },
                      icon: const Icon(Icons.upload_rounded),
                      label: const Text("Change Logo"),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF4F46E5),
                        textStyle:
                            GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: aboutController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: "About Us",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  await context.read<CompanyCubit>().updateCompanyProfile(
                        newLogoUrl: newLogoUrl ?? '',
                        newDescription: aboutController.text,
                      );

                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Profile updated successfully")),
                  );
                },
                child: const Text("Save"),
              ),
            ],
          );
        });
      },
    );
  }
}

void _showChangePasswordDialog(BuildContext context) {
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
              child: SizedBox(
                width: 200,
                height: 200,
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
                      await CompanyWebService().requestPasswordResetOTP(email);
                      setState(() {
                        isOTPSent = true;
                        secondsRemaining = 600;
                      });
                      startCountdown(setState);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("OTP sent to your email")),
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
                child: Text(isOTPSent ? "Confirm" : "Send OTP"),
              ),
            ],
          );
        },
      );
    },
  );
}

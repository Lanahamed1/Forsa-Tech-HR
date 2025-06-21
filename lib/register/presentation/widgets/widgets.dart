import 'package:flutter/material.dart';

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
}

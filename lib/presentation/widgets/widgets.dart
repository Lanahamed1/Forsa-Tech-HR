import 'package:flutter/material.dart';
class Widgets {
  Widget buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        fillColor:  Colors.white,
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
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 26),
          child: Icon(icon, color: Colors.grey),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

 Widget buildSignInButton(
  BuildContext context,
  GlobalKey<FormState> formKey,
  {required VoidCallback onPressed}) // ✅ التأكد من أن `onPressed` مطلوب
 {
  return Container(
    width: double.infinity,
    height: 40,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(150),
    ),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(150),
        ),
        backgroundColor: const Color.fromARGB(246, 0, 25, 150),
      ),
      onPressed: () { 
        if (formKey.currentState!.validate()) {
          onPressed(); // ✅ استدعاء `onPressed` الذي يتم تمريره من `BlocBuilder`
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

  // Widget buildDivider(){
  //   return Expanded(
  //     flex: 2,
  //     child: Divider(
  //       thickness: 0.5,
  //       color:Colors.black,
  //         height: 10,
  //     ),
  //   );
    
  // }


Widget buildDivider(double endIndent) {
    return Divider(
      height: 10,
      endIndent: endIndent,
      thickness: 2,
      color: Color.fromARGB(246, 0, 25, 150),
    );
}}

  // const Expanded(
  //                                 child: Divider(
  //                                     thickness: 0.5, color: Colors.grey)),
  //                           ])),
import 'package:flutter/material.dart';
import 'package:x_demo_app/theme/theme.dart';

class AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const AuthField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText,
      controller: controller,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(
            color: Palette.blueColor,
            width: 3,
          ),
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(
              color: Palette.greyColor,
              width: 1,
            )),
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 18,
        ),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }
}

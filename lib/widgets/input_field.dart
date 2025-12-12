import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool obscureText;
  final Widget? suffixIcon;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool isDarkMode;

  const InputField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.obscureText = false,
    this.suffixIcon,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.grey.shade300 : null,
        ),
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.grey.shade500 : Colors.grey,
        ),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey.shade700 : const Color(0xFFE5E7EB),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: Colors.deepPurple, width: 2),
        ),
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        suffixIcon: suffixIcon,
        fillColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
        filled: true,
      ),
    );
  }
}
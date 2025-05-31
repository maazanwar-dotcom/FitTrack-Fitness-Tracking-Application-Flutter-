import 'package:flutter/material.dart';

class CustomFormFields extends StatelessWidget {
  final bool obsecure;
  final String hintText;
  final String? label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const CustomFormFields({
    super.key,
    this.obsecure = false,
    required this.hintText,
    this.label,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: TextFormField(
        obscureText: obsecure,
        controller: controller,
        validator: validator,
        decoration: InputDecoration(hintText: hintText, labelText: label),
      ),
    );
  }
}

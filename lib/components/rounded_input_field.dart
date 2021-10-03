import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './text_field_container.dart';
import '../constants.dart';

class RoundedInputField extends StatelessWidget {
  final String hintText;
  final String? defaultValue;
  final IconData icon;
  final TextEditingController? controller;
  final ValueChanged<String> onChanged;
  final bool enabled;

  const RoundedInputField({
    this.defaultValue,
    required this.hintText,
    this.icon = Icons.person,
    this.controller,
    this.enabled = true,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if(controller != null)
      controller!.text = defaultValue ?? '';

    return TextFieldContainer(
      child: TextField(
        controller: controller ?? TextEditingController(text: defaultValue),
        onChanged: onChanged,
        enabled: enabled,
        cursorColor: kPrimaryColor,
        style: GoogleFonts.poppins(),
        autocorrect: false,
        enableSuggestions: false,
        autofillHints: null,
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: kPrimaryColor,
          ),
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
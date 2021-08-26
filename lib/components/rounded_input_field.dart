import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './text_field_container.dart';
import '../constants.dart';

class RoundedInputField extends StatelessWidget {
  final String hintText;
  final String? defaultValue;
  final IconData icon;
  final ValueChanged<String> onChanged;

  const RoundedInputField({
    this.defaultValue,
    required this.hintText,
    this.icon = Icons.person,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        controller: TextEditingController(text: defaultValue),
        onChanged: onChanged,
        cursorColor: kPrimaryColor,
        style: GoogleFonts.delius(),
        autocorrect: false,
        enableSuggestions: false,
        autofillHints: null,
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: kPrimaryColor,
          ),
          hintText: hintText,
          hintStyle: GoogleFonts.delius(),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
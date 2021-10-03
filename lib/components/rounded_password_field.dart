import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './text_field_container.dart';
import '../constants.dart';

class RoundedPasswordField extends StatelessWidget {
  final String? defaultValue;
  final ValueChanged<String> onChanged;
  final IconData icon;
  final bool enabled;

  const RoundedPasswordField({
    this.defaultValue,
    required this.onChanged,
    this.icon = Icons.lock,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        controller: TextEditingController(text: defaultValue),
        enabled: enabled,
        obscureText: true,
        onChanged: onChanged,
        cursorColor: kPrimaryColor,
        autocorrect: false,
        enableSuggestions: false,
        autofillHints: null,
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          hintText: "Password",
          hintStyle: GoogleFonts.poppins(),
          icon: Icon(
            icon,
            color: kPrimaryColor,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
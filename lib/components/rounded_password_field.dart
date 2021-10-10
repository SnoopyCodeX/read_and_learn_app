import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './text_field_container.dart';
import '../constants.dart';

class RoundedPasswordField extends StatefulWidget {
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
  _RoundedPasswordFieldState createState() => _RoundedPasswordFieldState();
}

class _RoundedPasswordFieldState extends State<RoundedPasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        controller: TextEditingController(text: widget.defaultValue),
        enabled: widget.enabled,
        obscureText: _obscured,
        onChanged: widget.onChanged,
        cursorColor: kPrimaryColor,
        autocorrect: false,
        enableSuggestions: false,
        autofillHints: null,
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          hintText: "Password",
          hintStyle: GoogleFonts.poppins(),
          icon: Icon(
            widget.icon,
            color: kPrimaryColor,
          ),
          border: InputBorder.none,
          suffix: TextButton(
            onPressed: () => setState(() => _obscured = !_obscured),
            child: Text(
              _obscured ? 'Show' : 'Hide',
              style: GoogleFonts.poppins(
                color: kPrimaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
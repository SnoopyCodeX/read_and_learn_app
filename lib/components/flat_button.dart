import 'package:flutter/material.dart';

class FlatButton extends StatelessWidget {
  final EdgeInsets? padding;
  final String text;
  final Function press;
  final Color backgroundColor, textColor;
  final double width, height;

  const FlatButton({
    required this.text,
    required this.press,
    this.width = 88,
    this.height = 44,
    this.padding,
    this.backgroundColor = Colors.grey,
    this.textColor = Colors.black
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        primary: textColor,
        minimumSize: Size(width, height),
        padding: padding ?? EdgeInsets.symmetric(horizontal: 16),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2.0)),
        ),
        backgroundColor: backgroundColor,
      ),
      onPressed: press as void Function()?, 
      child: Text(text), 
    );
  }
}
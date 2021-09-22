import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomNavBar extends StatefulWidget {
  final String imageUrl;
  final String? title;

  const CustomNavBar(this.imageUrl, {
    this.title,
    Key? key,
  }) : super(key: key);

  @override
  _CustomNavBarState createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.menu_outlined),
          onPressed: () => ZoomDrawer.of(context)!.toggle(),
        ),
        Spacer(),
        Text(
          widget.title ?? '',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Spacer(),
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.purpleAccent,
          backgroundImage: NetworkImage(widget.imageUrl),
        ),
      ],
    );
  }
}
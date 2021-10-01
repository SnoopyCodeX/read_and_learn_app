import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../constants.dart';
import '../../../../models/classroom_model.dart';

class CustomNavBar extends StatefulWidget {
  final Classroom classroom;
  final void Function(String option) onOptionSelected;
  final void Function() resetSelectedRoom;

  const CustomNavBar({
    required this.classroom,
    required this.onOptionSelected,
    required this.resetSelectedRoom,
  });

  @override
  _CustomNavBarState createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          InkWell(
            onTap: () {
              widget.resetSelectedRoom();
              Navigator.of(context).pop();
            },
            borderRadius: BorderRadius.all(Radius.circular(14)),
            child: Container(
              child: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.black),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(14)), 
                border: Border.all(
                  color: kPrimaryLightColor,
                  width: 2,
                ),
              ),
            ),
          ),
          SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.classroom.name,
                textAlign: TextAlign.start,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                widget.classroom.section,
                textAlign: TextAlign.start,
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          Spacer(),
          PopupMenuButton<String>(
            icon: Icon(Icons.menu_open_outlined),
            itemBuilder: (builder) => [
              PopupMenuItem<String>(
                value: 'Leave class',
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.exit_to_app_outlined),
                    SizedBox(width: 10),
                    Text(
                      'Leave class',
                      style: GoogleFonts.poppins(),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'Reset all progress',
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.restore_outlined),
                    SizedBox(width: 10),
                    Text(
                      'Reset all progress',
                      style: GoogleFonts.poppins(),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: widget.onOptionSelected,
          ),
        ],
      ),
    );
  }
}
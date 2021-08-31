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
            itemBuilder: (builder) => CLASSROOM_PANEL_OPTIONS.map((option) {
              IconData _icondata = Icons.copy_outlined;
              _icondata = option == 'Copy class code' ? _icondata : _icondata;
              _icondata = option == 'Edit' ? Icons.edit_outlined : _icondata;
              _icondata = option == 'Delete' ? Icons.delete_outlined : _icondata;
 
              return PopupMenuItem<String>(
                value: option,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(_icondata),
                    SizedBox(width: 10),
                    Text(
                      option,
                      style: GoogleFonts.poppins(),
                    ),
                  ],
                ),
              );
            }).toList(),
            onSelected: widget.onOptionSelected,
          ),
        ],
      ),
    );
  }
}
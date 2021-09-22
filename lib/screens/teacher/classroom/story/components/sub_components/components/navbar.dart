import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../constants.dart';
import '../../../../../../../models/story_model.dart';

class CustomNavBar extends StatefulWidget {
  final Story story;
  final void Function(String option) onOptionSelected;
  final void Function() resetSelectedStory;

  const CustomNavBar({
    required this.story,
    required this.onOptionSelected,
    required this.resetSelectedStory,
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
              widget.resetSelectedStory();
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
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    widget.story.title,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.menu_open_outlined),
                  itemBuilder: (builder) => STORY_PANEL_OPTIONS.map((option) {
                    IconData _icondata = Icons.copy_outlined;
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
          ),
        ],
      ),
    );
  }
}
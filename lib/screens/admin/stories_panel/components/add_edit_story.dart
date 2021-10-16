import 'package:bottom_bar/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../models/story_model.dart';
import 'finished_students_screen.dart';
import 'pending_students_screen.dart';
import 'story_form.dart';

class AddEditStoryScreen extends StatefulWidget {
  final void Function()? refreshList;
  final Story? story;

  const AddEditStoryScreen({ 
    Key? key, 
    this.story,
    this.refreshList,
  }) : super(key: key);

  @override
  _AddEditStoryScreenState createState() => _AddEditStoryScreenState();
}

class _AddEditStoryScreenState extends State<AddEditStoryScreen> {
  int selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: selectedIndex == 0 
          ? widget.story == null 
            ? Container() 
            : FinishedStudentScreen(widget.story!)
          : selectedIndex == 2
            ? widget.story == null 
              ? Container() 
              : PendingStudentScreen(widget.story!)
            : StoryForm(
                story: widget.story,
                refreshList: widget.refreshList,
              ),
      ),
      bottomNavigationBar: widget.story == null 
        ? null
        : BottomBar(
            backgroundColor: Colors.white,
            selectedIndex: selectedIndex,
            onTap: (index) => setState(() => selectedIndex = index),
            items: [
              BottomBarItem(
                icon: Icon(Icons.people_outlined),
                title: Text(
                  'Finished Students',
                  style: GoogleFonts.poppins(),
                ),
                activeColor: Colors.black87,
                inactiveColor: Colors.black,
              ),
              BottomBarItem(
                icon: Icon(Icons.book_outlined),
                title: Text(
                  'Story Details',
                  style: GoogleFonts.poppins(),
                ),
                activeColor: Colors.black87,
                inactiveColor: Colors.black,
              ),
              BottomBarItem(
                icon: Icon(Icons.people_alt_outlined),
                title: Text(
                  'Pending Students',
                  style: GoogleFonts.poppins(),
                ),
                activeColor: Colors.black87,
                inactiveColor: Colors.black,
              ),
            ],
          ),
    );
  }  
}
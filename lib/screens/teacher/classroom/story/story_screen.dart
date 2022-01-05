import 'package:bottom_bar/bottom_bar.dart';
// import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../constants.dart';
import '../../../../models/story_model.dart';
import '../../../../providers/temp_variables_provider.dart';
import 'components/body.dart';

class StoryScreen extends StatefulWidget {
  final void Function(Story story) openStory;
  final void Function() resetOpenedStory;
  final void Function() refreshStoryList;
  final Story story;

  const StoryScreen(
      this.story, this.refreshStoryList, this.openStory, this.resetOpenedStory);

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.resetOpenedStory();
        Navigator.of(context).pop();

        return true;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey.shade100,
          body: SingleChildScrollView(
            child: Body(widget.story, widget.refreshStoryList, widget.openStory,
                widget.resetOpenedStory),
          ),
          bottomNavigationBar: BottomBar(
            backgroundColor: Colors.white,
            selectedIndex: Provider.of<TempVariables>(context, listen: true)
                .tempStoryIndex,
            onTap: (index) => Provider.of<TempVariables>(context, listen: false)
                .setTempStoryIndex(index),
            items: [
              BottomBarItem(
                icon: Icon(Icons.people_outlined),
                title: Text(
                  'Finished Students',
                  style: GoogleFonts.poppins(),
                ),
                activeColor: kPrimaryColor,
                inactiveColor: Colors.black,
              ),
              BottomBarItem(
                icon: Icon(Icons.book_outlined),
                title: Text(
                  'Main Story',
                  style: GoogleFonts.poppins(),
                ),
                activeColor: kPrimaryColor,
                inactiveColor: Colors.black,
              ),
              BottomBarItem(
                icon: Icon(Icons.people_alt_outlined),
                title: Text(
                  'Pending Students',
                  style: GoogleFonts.poppins(),
                ),
                activeColor: kPrimaryColor,
                inactiveColor: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

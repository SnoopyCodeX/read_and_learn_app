import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../constants.dart';
import '../../../../../../models/story_model.dart';
import '../../../../../../services/story_services.dart';
import '../../../../../../utils/utils.dart';
import 'components/edit_story.dart';
import 'components/navbar.dart';

class MainStoryScreen extends StatefulWidget {
  final void Function(Story story) openStory;
  final void Function() resetOpenedStory;
  final void Function() refreshStoryList;
  final Story story;

  const MainStoryScreen(this.story, this.refreshStoryList, this.openStory, this.resetOpenedStory);

  @override
  _MainStoryScreenState createState() => _MainStoryScreenState();
}

class _MainStoryScreenState extends State<MainStoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomNavBar(
          story: widget.story,
          resetSelectedStory: () => widget.resetOpenedStory(),
          onOptionSelected: (option) {
            switch(option) {
              case 'Edit':
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EditStoryScreen(widget.story, widget.refreshStoryList, widget.openStory),
                  ),
                );
              break;

              case 'Delete':
                _showDeleteDialog();
              break;
            }
          },
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.86,
          child: Text(
            widget.story.content,
            style: GoogleFonts.poppins(
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog() {
    Utils.showAlertDialog(
      context: context, 
      title: 'Confirm Delete', 
      message: 'Are you sure you want to delete this story?', 
      actions: [
        TextButton(
          onPressed: () => _deleteStory(),
          child: Text(
            'Yes',
            style: GoogleFonts.poppins(
              color: kPrimaryColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          child: Text(
            'No',
            style: GoogleFonts.poppins(
              color: kPrimaryColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _deleteStory() async {
    // Close previous dialog
    Navigator.of(context, rootNavigator: true).pop();

    Utils.showProgressDialog(
      context: context, 
      message: 'Deleting story...',
    );

    await StoryService.instance.deleteStory(widget.story.id);

    // Close progress dialog
    Navigator.of(context, rootNavigator: true).pop();

    Utils.showSnackbar(
      context: context, 
      message: 'Story has been deleted successfully!',
    );

    // Refresh story list
    widget.refreshStoryList();

    // Close story
    Navigator.of(context).pop();
  }
}
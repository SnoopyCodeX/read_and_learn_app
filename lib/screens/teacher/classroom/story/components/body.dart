import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../models/story_model.dart';
import '../../../../../providers/temp_variables_provider.dart';
import 'sub_components/finished_students_screen.dart';
import 'sub_components/main_story.dart';
import 'sub_components/pending_students_screen.dart';

class Body extends StatefulWidget {
  final void Function(Story story) openStory;
  final void Function() resetOpenedStory;
  final void Function() refreshStoryList;
  final Story story;

  const Body(this.story, this.refreshStoryList, this.openStory, this.resetOpenedStory);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int _storyPageIndex = 1;

  @override
  void initState() {
    super.initState();

    Provider.of<TempVariables>(context, listen: false).storyIndexChanged = () {
      setState(() {
        _storyPageIndex = Provider.of<TempVariables>(context, listen: false).tempStoryIndex;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if(_storyPageIndex == 0)
          FinishedStudentScreen(widget.story)
        else if(_storyPageIndex == 1)
          MainStoryScreen(widget.story, widget.refreshStoryList, widget.openStory, widget.resetOpenedStory)
        else if(_storyPageIndex == 2)
          PendingStudentScreen(widget.story),
      ],
    );
  }
}
// import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';

import '../../../../models/story_model.dart';
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
          body: Body(widget.story, widget.refreshStoryList, widget.openStory,
              widget.resetOpenedStory),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../models/story_model.dart';
import 'sub_components/main_story.dart';

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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MainStoryScreen(
      widget.story, 
      widget.refreshStoryList, 
      widget.openStory, 
      widget.resetOpenedStory,
    );
  }
}
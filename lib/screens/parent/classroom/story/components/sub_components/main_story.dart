import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../constants.dart';
import '../../../../../../models/story_model.dart';
import '../../../../../../utils/utils.dart';
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
            
          },
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.86,
          child: RichText(
            text: TextSpan(
              children: _buildTextSpans(widget.story.content),
            ),
          ),
        ),
      ],
    );
  }

  List<TextSpan> _buildTextSpans(String story) {
    FlutterTts tts = FlutterTts();

    List<TextSpan> _spans = [];
    List<String> _parts = [];
    String _story = '$story';
    _parts = _story.split(' ');

    for(String part in _parts)
      _spans.add(
        TextSpan(
          text: '$part ',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 18,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              if(part == '\n')
                return;
              
              await tts.setLanguage('en-US');
              part = part.replaceAll("[.]", "");

              Utils.showAlertDialog(
                context: context, 
                title: 'Pronounciation Demo', 
                message: 'Word: "$part"', 
                actions: [
                  TextButton(
                    onPressed: () async {
                      await tts.speak(part);
                    }, 
                    child: Text(
                      'Repeat',
                      style: GoogleFonts.poppins(
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                ],
              );

              await tts.speak(part);
            },
        ),
      );

    return _spans;
  }
}
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache/flutter_cache.dart' as Cache;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../constants.dart';
import '../../../../../../models/result_model.dart';
import '../../../../../../models/story_model.dart';
import '../../../../../../models/user_model.dart';
import '../../../../../../services/user_progress_services.dart';
import '../../../../../../utils/utils.dart';
import 'components/navbar.dart';

class MainStoryScreen extends StatefulWidget {
  final void Function(Story story) openStory;
  final void Function() resetOpenedStory;
  final void Function() refreshStoryList;
  final Story story;

  const MainStoryScreen(
      this.story, this.refreshStoryList, this.openStory, this.resetOpenedStory);

  @override
  _MainStoryScreenState createState() => _MainStoryScreenState();
}

class _MainStoryScreenState extends State<MainStoryScreen> {
  User? _user;

  @override
  void initState() {
    super.initState();

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    Map<String, dynamic> json = await Cache.load('user', <String, dynamic>{});
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      setState(() {
        _user = User.fromJson(json);
      });
      print('user not null anymore');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomNavBar(
          user: _user,
          story: widget.story,
          resetSelectedStory: () => widget.resetOpenedStory(),
          onOptionSelected: (option) {
            Utils.showAlertDialog(
              context: context,
              title: "Confirm Action",
              message: "Do you really want to reset your progress?",
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context, rootNavigator: true).pop();

                    Utils.showProgressDialog(
                      context: context,
                      message: "Resetting progress...",
                    );

                    Result<dynamic> result =
                        await UserProgressService.instance.resetUserProgress(
                      _user!.id,
                      widget.story.classroom,
                      widget.story.id,
                    );
                    Navigator.of(context, rootNavigator: true).pop();

                    Utils.showSnackbar(
                      context: context,
                      message: result.message,
                      backgroundColor:
                          result.hasError ? Colors.red : Colors.green,
                      textColor: Colors.white,
                    );
                  },
                  child: Text(
                    'Yes',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                  child: Text(
                    'No',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
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
    tts.setPitch(1.5);

    List<TextSpan> _spans = [];
    List<String> _parts = [];
    String _story = '$story';

    if (!_story.endsWith('.')) _story += '.';

    _parts = _story.split('');

    String _word = '';
    for (String part in _parts) {
      if (part == '\n' || part == ' ' || part == '.') {
        String _complete = _word + part;

        _spans.add(
          TextSpan(
            text: '$_complete',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 18,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                _complete = _complete.replaceAll('\n', '').replaceAll(' ', '');

                await tts.setLanguage('en-US');
                _complete = _complete.replaceAll(".", "");

                if (_complete.isEmpty) return;

                Utils.showAlertDialog(
                  context: context,
                  title: 'Word Demonstration',
                  message: 'Word: "$_complete"',
                  actions: [
                    TextButton(
                      onPressed: () async {
                        await tts.speak(_complete);
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

                await tts.speak(_complete);
              },
          ),
        );

        _word = '';
      } else
        _word += part;
    }

    return _spans;
  }
}

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../../../../../constants.dart';
import '../../../../../../../models/story_model.dart';
import '../../../../../../../utils/utils.dart';

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
  SpeechToText? stt;
  List<double> _accuracies = [];
  DateTime? _start, _end;
  IconData _micIcon = Icons.mic_outlined;
  bool _isListening = false;
  double _wordsPerMinute = 0;
  double _accuracy = 0;
  double _lengthOfStory = 0;

  @override
  void initState() {
    super.initState();

    // Get the number of words in the story
    _lengthOfStory = widget.story.content
      .replaceAll("\n", "")
      .split(" ").length
      .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    print('Started: $_isListening');

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
                AvatarGlow(
                  repeat: true,
                  showTwoGlows: true,
                  animate: _isListening,
                  glowColor: kPrimaryColor,
                  endRadius: 40,
                  child: IconButton(
                    icon: Icon(_micIcon),
                    onPressed: () {
                      if(!_isListening)
                        _showStartRecordingDialog();
                      else
                        _stopListening();
                    },
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.menu_open_outlined),
                  itemBuilder: (builder) => [
                    PopupMenuItem<String>(
                      value: 'Reset progress',
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.restore_outlined),
                          SizedBox(width: 10),
                          Text(
                            'Reset progress',
                            style: GoogleFonts.poppins(),
                          ),
                        ],
                      ),
                    )
                  ],
                  onSelected: widget.onOptionSelected,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showStartRecordingDialog() {
    Utils.showAlertDialog(
      context: context, 
      title: 'Heads Up!', 
      message: 'Before proceeding, please make sure that no other sounds is heard other than your child\'s voice.', 
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            setState(() {
              _isListening = true;
              _micIcon = Icons.mic_off_outlined;

              if(_isListening) {
                _accuracies = <double>[];
                _start = DateTime.now();
              }
            });

            _startListening();
          }, 
          child: Text(
            'Start',
            style: GoogleFonts.poppins(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(), 
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _stopListening() {
    _end = DateTime.now();

    // Compute speed of reader
    _wordsPerMinute = _accuracies.length / (_end!.difference(_start!).inMinutes);

    // Compute reader's accuracy
    _accuracies.forEach((accuracy) => _accuracy += accuracy);
    _accuracy /= _lengthOfStory;
    _accuracy *= 100;

    String conclusion = (_wordsPerMinute >= 107 && _accuracy >= 70) 
      ? "Congratulations, you passed! Thank you for taking your time in learning to read." 
      : "Sorry, you failed. Practice more, you'll get it right next time!";

    // Display accuracy and speed of reader
    Utils.showAlertDialog(
      context: context, 
      title: "Result", 
      message: "Words Per Minute (WPM): $_wordsPerMinute\nAccuracy: ${_accuracy.toStringAsFixed(2)}%\n\n\n$conclusion", 
      actions: [],
    );

     setState(() {
      _isListening = false;
      _micIcon = Icons.mic_outlined;

      _start = _end = null;
      _wordsPerMinute = 0;
      _accuracies = <double>[];
    });

    stt!.stop();
    stt = null;
  }

  Future<void> _startListening() async {
    PermissionStatus status = await Permission.speech.request();

    if(status != PermissionStatus.granted) {
      Utils.showSnackbar(
        context: context,
        message: 'Record audio permission was revoked!',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );

      setState(() {
        _isListening = false;
        _micIcon = Icons.mic_outlined;

        stt = _start = null;
      });

      return;
    }

    stt = SpeechToText();

    bool isAvailable = await stt!.initialize(
      onStatus: (status) => print('STT Status: $status'),
      onError: (error) => print('STT Error: $error'),
      finalTimeout: Duration(minutes: 30),
    );

    if(isAvailable) 
      stt!.listen(
        listenFor: Duration(minutes: 30),
        pauseFor: Duration(minutes: 1),
        onResult: (result) {                                                               
          if(result.hasConfidenceRating && result.confidence > 0)
            _accuracies.add(result.confidence);
          print(result.recognizedWords);
        }
      );
    else {
      setState(() {
        _isListening = false;
        _micIcon = Icons.mic_outlined;

        stt = _start = null;
      });

      Utils.showAlertDialog(
        context: context, 
        title: 'Unsupported STTR!', 
        message: 'Sorry, Speech to Text Recognition is not supported on your device. This is a crucial requirement for this app because this is what determines the accuracy of the pronounced words.', 
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(), 
            child: Text(
              'Okay',
              style: GoogleFonts.poppins(
                color: Colors.deepOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    }
  }
}
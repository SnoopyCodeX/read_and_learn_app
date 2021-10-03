import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache/flutter_cache.dart' as Cache;
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../../constants.dart';
import '../../../../../../../models/result_model.dart';
import '../../../../../../../models/story_model.dart';
import '../../../../../../../models/user_model.dart';
import '../../../../../../../models/user_progress_model.dart';
import '../../../../../../../services/user_progress_services.dart';
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
      message: 'Before proceeding, please make sure that no other sounds is heard other than your child\'s voice. Please make your voice loud and clear for better result.', 
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

  Future<void> _saveProgress({
    required bool status,
    required double accuracy,
    required double wpm,
  }) async {
    Navigator.of(context).pop();

    Utils.showProgressDialog(
      context: context, 
      message: 'Saving progress...',
    );

    Map<String, dynamic> data = await Cache.load('user', <String, dynamic>{});
    User userData = User.fromJson(data);
    Result<List<UserProgress>?> result = await UserProgressService.instance.getUserProgress(
      userData.id, 
      widget.story.classroom,
    );

    UserProgress progress;
    if(result.hasError) 
      progress = UserProgress(
        id: Uuid().v4(),
        accuracy: accuracy.toStringAsFixed(2),
        speed: wpm.toStringAsFixed(2),
        classId: widget.story.classroom,
        userId: userData.id,
        storyId: widget.story.id,
        status: status ? STATUS_FINISHED_READING : STATUS_STILL_READING,
        photoUrl: userData.photo,
        name: userData.childName,
        dateFinished: status ? Jiffy(DateTime.now()).format("MMMM do yyyy h:mm a") : "",
        dateStarted: Jiffy(DateTime.now()).format("MMMM do yyyy h:mm a"),
      );
    else 
    {
      Map<String, dynamic> oldProgress = <String, dynamic>{};
      for(UserProgress oldData in (result.data as List<UserProgress>))
        if(oldData.storyId == widget.story.id) {
          oldProgress = oldData.toJson();
          break;
        }

      // Progress for the story exists, just update the progress
      if(oldProgress.isNotEmpty) {
        oldProgress['accuracy'] = accuracy.toStringAsFixed(2);
        oldProgress['speed'] = wpm.toStringAsFixed(2);
        oldProgress['status'] = status ? STATUS_FINISHED_READING : STATUS_STILL_READING;
        oldProgress['date_finished'] = status ? Jiffy(DateTime.now()).format("MMMM do yyyy h:mm:ss a") : "";
        progress = UserProgress.fromJson(oldProgress);
      } else 
        progress = UserProgress(
          id: Uuid().v4(),
          accuracy: accuracy.toString(),
          speed: wpm.toString(),
          classId: widget.story.classroom,
          userId: userData.id,
          storyId: widget.story.id,
          status: status ? STATUS_FINISHED_READING : STATUS_STILL_READING,
          photoUrl: userData.photo,
          name: userData.childName,
          dateFinished: status ? Jiffy(DateTime.now()).format("MMMM do yyyy h:mm:ss a") : "",
          dateStarted: Jiffy(DateTime.now()).format("MMMM do yyyy h:mm:ss a"),
        );
    }

    await UserProgressService.instance.setUserProgress(progress);

    Navigator.of(context).pop();

    Utils.showSnackbar(
      context: context, 
      message: "Your progress has been saved!",
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }
 
  void _stopListening() {
    _end = DateTime.now();

    // Compute speed of reader
    double seconds = _end!.difference(_start!).inSeconds.toDouble();
    double mins = seconds / 60.0;
    _wordsPerMinute = (_accuracies.length.toDouble() / mins);
    
    print("Seconds: $seconds");
    print("Minutes: $mins");
    print("WPM: $_wordsPerMinute");

    // Compute reader's accuracy
    _accuracies.forEach((accuracy) => _accuracy += accuracy);
    _accuracy /= (_lengthOfStory / 100);

    _accuracy *= 100;

    String conclusion = (_wordsPerMinute >= 107 && _accuracy >= 70) 
      ? "Congratulations, you passed! Thank you for taking your time in learning to read." 
      : "Sorry, you failed, your WPM(Words per Minute) should be atleast 107 and your accuracy should be atleast 70%. Practice more, you'll get it right next time!";

    // Display accuracy and speed of reader
    Utils.showAlertDialog(
      context: context,
      dismissable: false,
      title: "Analysis Result", 
      message: "Words Per Minute (WPM): ${_wordsPerMinute.toStringAsFixed(2)}\nAccuracy: ${_accuracy.toStringAsFixed(2)}%\n\n\n$conclusion", 
      actions: [
        TextButton(
          onPressed: () => _saveProgress(
            status: (_wordsPerMinute >= 107 && _accuracy >= 60),
            wpm: _wordsPerMinute,
            accuracy: _accuracy,
          ), 
          child: Text(
            'Okay',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.green,
            ),
          ),
        )
      ],
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
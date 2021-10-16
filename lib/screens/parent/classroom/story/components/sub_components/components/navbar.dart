import 'dart:convert';
import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:device_info/device_info.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache/flutter_cache.dart' as Cache;
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as Http;
import 'package:jiffy/jiffy.dart';
import 'package:mp3_info/mp3_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pusher_client/pusher_client.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../../constants.dart';
import '../../../../../../../http/http_handler.dart' as HttpHandler;
import '../../../../../../../models/result_model.dart';
import '../../../../../../../models/story_model.dart';
import '../../../../../../../models/user_model.dart';
import '../../../../../../../models/user_progress_model.dart';
import '../../../../../../../services/user_progress_services.dart';
import '../../../../../../../services/user_services.dart';
import '../../../../../../../utils/utils.dart';
import 'result.dart';

class CustomNavBar extends StatefulWidget {
  final Story story;
  final User? user;
  final void Function(String option) onOptionSelected;
  final void Function() resetSelectedStory;

  const CustomNavBar({
    required this.user,
    required this.story,
    required this.onOptionSelected,
    required this.resetSelectedStory,
  });

  @override
  _CustomNavBarState createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  RecordMp3 _recordMp3 = RecordMp3.instance;
  IconData _micIcon = Icons.mic_outlined;
  String _audioPath = "";
  bool _isListening = false;
  double _wordsPerMinute = 0;
  double _accuracy = 0;
  int _lengthOfStory = 0;

  @override
  void initState() {
    super.initState();

    // Get the number of words in the story
    _lengthOfStory = widget.story.content
      .replaceAll("\n", "")
      .split(" ").length;
  }

  @override
  Widget build(BuildContext context) {
    print('Started: $_isListening');

    return Container(
      padding: EdgeInsets.all(20),
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
                  glowColor: Colors.red,
                  endRadius: 40,
                  child: IconButton(
                    icon: Icon(_micIcon),
                    onPressed: () {
                      if(!_isListening)
                        _showStartRecordingDialog();
                      else
                        _showStopRecordingDialog();
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

  void _showStopRecordingDialog() {
    _recordMp3.pause();

    Utils.showAlertDialog(
      context: context, 
      title: 'Recording Paused', 
      message: 'What would you like to do?', 
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();

            Utils.showSnackbar(
              context: context, 
              message: "Recording resumed",
              backgroundColor: Colors.amber,
              textColor: Colors.white,
            );

            _recordMp3.resume();
          },
          child: Text(
            'Resume',
            style: GoogleFonts.poppins(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed: () => _stopListening(),
          child: Text(
            'Save',
            style: GoogleFonts.poppins(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();

            Utils.showSnackbar(
              context: context, 
              message: "Recording stopped",
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );

            _recordMp3.stop();

            File audioFile = File(_audioPath);
            audioFile.delete();

            setState(() {
              _isListening = false;
              _micIcon = Icons.mic_outlined;

              _accuracy = 0;
              _wordsPerMinute = 0;
            });
          }, 
          child: Text(
            'Stop',
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
    Navigator.of(context, rootNavigator: true).pop();

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
 
  Future<void> _stopListening() async {
    Navigator.of(context, rootNavigator: true).pop();
    _recordMp3.stop();

    Utils.showProgressDialog(context: context, message: "Analyzing audio...");

    File audioFile = File(_audioPath);
    String audioUrl = (await UserService.instance.uploadAudio(widget.user!.id, audioFile)).data!;
    Http.Response response = await HttpHandler.postData(
      TRANSCRIBE_REST_API, 
      jsonEncode({"audioUrl": audioUrl, "userId": widget.user!.id}),
    );

    print('Response: ${response.body}');

    if(response.statusCode == HttpStatus.ok) {
      PusherClient pusher = PusherClient(PUSHER_APP_ID, PusherOptions(cluster: PUSHER_CLUSTER));
      Channel channel = pusher.subscribe(widget.user!.id);

      channel.bind(widget.user!.id, (event) {
        if(event != null) {
          Map<String, dynamic> data = (jsonDecode(event.data!) as Map<String, dynamic>);
          _showConclusion(data, audioFile);

          print("Data: ${event.data}");
          print("Json: ${event.toJson()}");

          pusher.unsubscribe(widget.user!.id);
          pusher.disconnect();
        }
      });
    } else {
      Navigator.of(context, rootNavigator: true).pop();

      Utils.showAlertDialog(
        context: context, 
        title: "Analyze Failed", 
        message: "Failed to analyze the audio, please check your internet connection and try again.", 
        actions: [],
      );
    }

    setState(() {
      _isListening = false;
      _micIcon = Icons.mic_outlined;
    });
  }

  Future<void> _startListening() async {
    try {
      Map<Permission, PermissionStatus> status = await [
        Permission.microphone, 
        Permission.storage,
      ].request();
      
      if(status[Permission.microphone] != PermissionStatus.granted || status[Permission.storage] != PermissionStatus.granted) {
        Utils.showSnackbar(
          context: context,
          message: 'Record Audio or Storage permission was revoked!',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      
        setState(() {
          _isListening = false;
          _micIcon = Icons.mic_outlined;
        });
      
        return;
      }

      Utils.showProgressDialog(context: context, message: "Setting up...");
      AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
      
      if(info.version.sdkInt >= 30) {
        PermissionStatus _status = await Permission.manageExternalStorage.request();

        if(_status != PermissionStatus.granted) {
           Utils.showSnackbar(
            context: context,
            message: 'Storage permission was revoked!',
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );

          setState(() {
            _isListening = false;
            _micIcon = Icons.mic_outlined;
          });
        
          return;
        }
      }

      Navigator.of(context, rootNavigator: true).pop();
      Utils.showProgressDialog(context: context, message: "Starting up...");
      _audioPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_MUSIC);
      _audioPath += "/${widget.user!.id}.mp3";

      await File(_audioPath).create();

      _recordMp3.start(_audioPath, (type) => Utils.showSnackbar(
        context: context, 
        message: "Error Type: ${type.toString()}",
        textColor: Colors.white,
        backgroundColor: Colors.red,
      ));
      
      Navigator.of(context, rootNavigator: true).pop();
      Utils.showSnackbar(
        context: context, 
        message: "Recording started",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } on Exception catch (e) {
      Navigator.of(context, rootNavigator: true).pop();

      Utils.showAlertDialog(
        context: context, 
        title: "Recording Failed", 
        message: "An error occured, this is usually because of Android 10+'s strict file permissions.\n\nError: ${e.toString()}.",
        actions: [],
      );
    }
  }

  Future<void> _showConclusion(Map<String, dynamic> data, File audioFile) async {
    Navigator.of(context, rootNavigator: true).pop();

    MP3Info mp3info = MP3Processor.fromFile(audioFile);
    String transcriptResult = data['transcript'];
    String status = data['status'];
    String failType = data['fail_type'];
    String failureDetail = data['detail'];
    String transcript = "";

    if(transcriptResult.isNotEmpty) {
      for(String str in transcriptResult.split(' ')) {
        List<String> _data = str.split(':');
        String _word = _data[0];
        double _confidence = double.parse(_data[1]);

        if(_confidence >= 0.75)
          transcript += '$_word ';
      }

      transcript = transcript.substring(0, transcript.length - 1);
    }

    /**
     *  A = document.frmOne.txtMinutesNumber.value
        B = document.frmOne.txtSecondsNumber.value
        W = document.frmOne.txtWordsNumber.value
        A = Number(A) // minutes
        B = Number(B) // seconds
        W = Number(W) // total words read
        C = (W / ((A * 60) + B)) * 60

        document.frmOne.txtFourthNumber.value = C
     */

    if(status == 'transcribed') {
      int minutes = mp3info.duration.inMinutes;
      int seconds = mp3info.duration.inSeconds % 60;
      int words = transcript.split(" ").length;

      _accuracy = 0;
      _wordsPerMinute = 0;

      // wpm = (totalWords / ((minutes x 60) + seconds)) x 60
      _wordsPerMinute = (_lengthOfStory / ((minutes * 60) + seconds)) * 60;

      // accuracy = (correctWords / totalWords) x 100
      _accuracy = ((words / _lengthOfStory).toDouble()) * 100;

      // WPM is atleast 107 and Accuracy is atleast 70%?
      bool status = ((transcript.length > 0 ? _accuracy : 0) >= 70) && 
                    ((transcript.length > 0 ? _wordsPerMinute : 0) > 107);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AnalysisResultView(
            duration: "${minutes < 10 ? '0' : ''}$minutes:${seconds < 10 ? '0' : ''}$seconds",
            transcript: transcript,
            transcriptResult: transcriptResult,
            accuracy: _accuracy,
            wpm: _wordsPerMinute,
            correctWords: transcript.split(' ').length,
            originalStory: widget.story.content,
            totalWords: _lengthOfStory,
            status: status,
            onSaveProgress: () => _saveProgress(
              status: status, 
              accuracy: _accuracy, 
              wpm: _wordsPerMinute,
            ),
          ),
        ),
      );
    } else 
      Utils.showAlertDialog(
        context: context, 
        title: "Analysis Failed",
        message: "$failureDetail \n\n Type: $failType", 
        actions: [],
      );

    audioFile.delete();
  }
}
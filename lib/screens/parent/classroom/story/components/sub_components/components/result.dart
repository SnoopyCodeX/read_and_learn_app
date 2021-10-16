import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../utils/utils.dart';
import 'transcript_result.dart';

class AnalysisResultView extends StatefulWidget {
  final void Function() onSaveProgress;
  final String duration, transcript, transcriptResult, originalStory;
  final double wpm, accuracy;
  final int correctWords, totalWords;
  final bool status;

  const AnalysisResultView({ 
    Key? key, 
    required this.duration, 
    required this.transcript, 
    required this.originalStory, 
    required this.wpm, 
    required this.accuracy, 
    required this.correctWords, 
    required this.totalWords, 
    required this.transcriptResult, 
    required this.onSaveProgress,
    required this.status,
  }) : super(key: key);

  @override
  _AnalysisResultViewState createState() => _AnalysisResultViewState();
}

class _AnalysisResultViewState extends State<AnalysisResultView> {
  @override
  Widget build(BuildContext context) {
    String message = "WPM(Words/minute): ${widget.transcript.length == 0 ? 0 : widget.wpm.toStringAsFixed(2)}\n";
    message += "Accuracy: ${widget.transcript.length == 0 ? 0 : widget.accuracy.toStringAsFixed(2)}%\n";
    message += "Corrects: ${widget.transcript.length == 0 ? 0 : widget.correctWords}\n";
    message += "Total Words: ${widget.originalStory.split(' ').length}\n";
    message += "Duration: ${widget.duration}\n\n";
    message += widget.status 
      ? "Congratulations, you passed! Thank you for taking your time in learning to read." 
      : "Sorry, you failed. Your WPM should be atleast 107 and your accuracy should be atleast 70% to be able to pass.";

    return WillPopScope(
      onWillPop: () async {
        Utils.showAlertDialog(
          context: context, 
          title: 'Confirm Action', 
          message: 'Do you really like to close this panel without saving your progress?', 
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                Navigator.of(context).pop();
              },
              child: Text(
                'Yes',
                style: GoogleFonts.poppins(
                  color: Colors.green,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(), 
              child: Text(
                'No',
                style: GoogleFonts.poppins(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );

        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: widget.status ? Colors.green : Colors.red,
          centerTitle: true,
          title: Text(
            'Analysis Result',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.save_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                Utils.showAlertDialog(
                  context: context, 
                  title: 'Confirm Action', 
                  message: 'Continue to save your progress?', 
                  actions: [
                    TextButton(
                      onPressed: () {
                        widget.onSaveProgress();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Yes',
                        style: GoogleFonts.poppins(
                          color: Colors.green,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context, rootNavigator: true).pop(), 
                      child: Text(
                        'No',
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraint) => Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Color(0xFFFFEEBA),
                      ),
                    ),
                    child: Text(
                      "The results that you see here are based on what our system has analyzed and perceived. Mispronounced words, your audio's quality, background noises will affect your overall calculated result.",
                      style: GoogleFonts.poppins(
                        color: Color(0xFF856404),
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.status 
                        ? Color(0xFFD4EDDA) 
                        : Color(0xFFF8D7DA),
                      border: Border.all(
                        color: widget.status 
                          ? Color(0xFFC3E6CB)
                          : Color(0xFFF5C6C),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: widget.status 
                          ? Color(0xFF155724)
                          : Color(0xFF721C24),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  ButtonTheme(
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                    height: 50,
                    child: MaterialButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TranscriptResultView(
                              transcriptResult: widget.transcriptResult, 
                              originalStory: widget.originalStory,
                              status: widget.status,
                            ),
                          ),
                        );
                      },
                      elevation: 0,
                      hoverElevation: 0,
                      highlightElevation: 0,
                      color: widget.status ? Colors.blue :  Color(0xFFFFF3CD),
                      minWidth: MediaQuery.of(context).size.width * 0.86,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: widget.status 
                          ? BorderSide.none 
                          : BorderSide(
                            color: Color(0xFFFFEEBA),
                          ),
                      ),
                      child: Container(
                        child: Center(
                          child: Text(
                            'View transcript result',
                            style: GoogleFonts.poppins(
                              color: widget.status ? Colors.white : Color(0xFF856404),
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
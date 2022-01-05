import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../utils/utils.dart';

class TranscriptResultView extends StatefulWidget {
  final String transcriptResult;
  final String originalStory;
  final bool status;
  const TranscriptResultView({
    Key? key,
    required this.transcriptResult,
    required this.originalStory,
    required this.status,
  }) : super(key: key);

  @override
  _TranscriptResultViewState createState() => _TranscriptResultViewState();
}

class _TranscriptResultViewState extends State<TranscriptResultView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.status ? Colors.green : Colors.red,
        centerTitle: true,
        title: Text(
          'Transcript Result',
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Original Story",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 5),
              Text(
                widget.originalStory,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Transcripted Text",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.blueAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              RichText(
                text: TextSpan(
                  children: _buildTextSpans(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<TextSpan> _buildTextSpans() {
    List<TextSpan> spans = [];
    List<String> storyParts = widget.originalStory.split(' ');
    List<String> transcriptParts = _compareAndFix(
      _removeSpecialChars(widget.originalStory),
      _removeSpecialChars(widget.transcriptResult),
    ).split(' ');

    if (widget.transcriptResult.length == 0) return [TextSpan(text: '')];

    // loop and compare words from original story and transcripted story
    for (int i = 0; i < storyParts.length; i++) {
      String str1 = storyParts[i];
      String str2 = transcriptParts[i];

      if (_removeSpecialChars(str1.toLowerCase()) !=
              _removeSpecialChars(str2.toLowerCase()) ||
          str2 == '*') {
        spans.add(TextSpan(
          text: str2 == '*' ? str1 : str2,
          style: GoogleFonts.poppins(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            decoration: TextDecoration.underline,
            decorationColor: Colors.red,
            decorationStyle: TextDecorationStyle.wavy,
          ),
        ));
      } else {
        spans.add(TextSpan(
          text: str2,
          style: GoogleFonts.poppins(
            color: Colors.green,
            fontSize: 16,
          ),
        ));
      }
    }

    return spans;
  }

  String _compareAndFix(String t1, String t2) {
    List<String> l1 = t1.split(" ");
    List<String> l2 = t2.split(" ");
    int index = 0;

    if (t2.length >= t1.length) {
      return t2;
    }

    while (true) {
      if (index >= l2.length) {
        break;
      }

      String str1 = l1[index].toLowerCase();
      String str2 = l2[index].toLowerCase();

      if (str1 != str2 && str2 != '*') {
        t2 = Utils.addCharAtPosition(t2, "* ", (index + str2.length));
        _compareAndFix(t1, t2);
        break;
      }

      index += 1;
    }

    while (l2.length < l1.length) {
      t2 += " *";
      l2 = t2.split(" ");
    }

    return t2;
  }

  String _removeSpecialChars(String string) {
    String str = string.replaceAll(RegExp(r"[^\w\s\'\’]+|\n+"), ' ');
    str = str.replaceAll(RegExp(r"[\'|\’]"), "");
    return str.replaceAll(RegExp(r'\s\s+'), ' ');
  }
}

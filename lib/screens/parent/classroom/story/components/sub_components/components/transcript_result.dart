import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    List<String> storyParts = widget.originalStory.split('');
    List<String> transcriptParts = widget.transcriptResult.split(' ');
    String word = '';
    int index = 0;

    if(widget.transcriptResult.length == 0) 
      return [TextSpan(text: '')];

    for(String part in storyParts) {
      if(part == '\n' || part == ' ' || part == '.') {
        String complete = word + part;

        if(index < transcriptParts.length) {
          double confidence = double.parse(transcriptParts[index++].split(':')[1]);

          spans.add(
            TextSpan(
              text: complete,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: (confidence > 0.75) ? FontWeight.w400 : FontWeight.bold,
                color: (confidence > 0.75) ? Colors.green : Colors.red,
              ),
            ),
          );
        } else 
           spans.add(
            TextSpan(
              text: complete,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          );

        word = '';
      } else
        word += part;
    }

    return spans;
  }
}
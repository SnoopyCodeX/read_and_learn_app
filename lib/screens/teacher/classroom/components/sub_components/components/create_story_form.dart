import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_and_learn/utils/utils.dart';

import '../../../../../../constants.dart';

class CreateStoryForm extends StatefulWidget {
  const CreateStoryForm({ Key? key }) : super(key: key);

  @override
  _CreateStoryFormState createState() => _CreateStoryFormState();
}

class _CreateStoryFormState extends State<CreateStoryForm> {
  TextEditingController? _titleController, _thumbNailController, _contentController;
  File? _selectedThumbnail;
  int _numLines = 0;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController();
    _thumbNailController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();

    _titleController!.dispose();
    _thumbNailController!.dispose();
    _contentController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();

        return true;
      },
      child: SafeArea(
        child: Scaffold(
          body: Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create a story',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 24
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      focusColor: kPrimaryColor,
                      hoverColor: kPrimaryColor,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: kPrimaryColor,
                          width: 3,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: kPrimaryColor,
                          width: 3,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: kPrimaryColor,
                          width: 3,
                        ),
                      ),
                      labelText: 'Title of the story',
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 18,
                        color: kPrimaryColor,
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: kPrimaryColor,
                        width: 3,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _thumbNailController,
                            enabled: false,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Select thumbnail photo...',
                              hintStyle: GoogleFonts.poppins(
                                color: kPrimaryColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        TextButton(
                          onPressed: () {}, // TODO: Pick thumbnail 
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              'Choose',
                              style: GoogleFonts.poppins(
                                color: kPrimaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: _numLines < 7 
                      ? 30 * 16
                      : _numLines.toDouble() * 30,
                    child: TextField(
                      decoration: InputDecoration(
                        focusColor: kPrimaryColor,
                        hoverColor: kPrimaryColor,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: kPrimaryColor,
                            width: 3,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: kPrimaryColor,
                            width: 3,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignLabelWithHint: true,
                        labelText: 'Content of the story',
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 18,
                          color: kPrimaryColor,
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                      controller: _contentController,
                      textAlign: TextAlign.start,
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.done,
                      maxLines: _numLines < 7 
                        ? 30 * 16
                        : _numLines * 30,
                      onChanged: (value) {
                        TextSelection prev = _contentController!.selection;
                
                        setState(() {
                          _numLines = '\n'.allMatches(value).length + 1;
                        });
                
                        _contentController!.text = value;
                        _contentController!.selection = TextSelection.collapsed(offset: prev.baseOffset);
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: MaterialButton(
                          onPressed: () => _showSaveDialog(), // TODO: Save story
                          color: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            child: Text(
                              'Create story',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSaveDialog() {
    Utils.showAlertDialog(
      context: context, 
      title: 'Confirm Action', 
      message: 'Are you sure you want to save this story?', 
      actions: []
    );
  }

  Future<void> _saveStory() async {

  }
}
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jiffy/jiffy.dart';
import 'package:ndialog/ndialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:read_and_learn/models/result_model.dart';
import 'package:read_and_learn/models/user_model.dart';
import 'package:read_and_learn/services/user_services.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../constants.dart';
import '../../../../../../models/classroom_model.dart';
import '../../../../../../models/story_model.dart';
import '../../../../../../services/story_services.dart';
import '../../../../../../utils/utils.dart';

class CreateStoryForm extends StatefulWidget {
  final void Function() refreshStoryList;
  final Classroom classroom;

  const CreateStoryForm(this.classroom, this.refreshStoryList);

  @override
  _CreateStoryFormState createState() => _CreateStoryFormState();
}

class _CreateStoryFormState extends State<CreateStoryForm> {
  TextEditingController? _titleController,
      _thumbNailController,
      _contentController;
  File? _selectedThumbnail;
  String _hintText = 'Select thumbnail photo...';
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
                      fontSize: 24,
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                              hintText: _hintText,
                              hintStyle: GoogleFonts.poppins(
                                color: kPrimaryColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        TextButton(
                          onPressed: () => _showProviderOptionDialog(),
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
                    height: _numLines < 7 ? 30 * 16 : _numLines.toDouble() * 30,
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
                      maxLines: _numLines < 7 ? 30 * 16 : _numLines * 30,
                      onChanged: (value) {
                        TextSelection prev = _contentController!.selection;

                        setState(() {
                          _numLines = '\n'.allMatches(value).length + 1;
                        });

                        _contentController!.text = value;
                        _contentController!.selection =
                            TextSelection.collapsed(offset: prev.baseOffset);
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: MaterialButton(
                          onPressed: () => _showSaveDialog(),
                          color: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 12),
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
      actions: [
        TextButton(
          onPressed: () => _saveStory(),
          child: Text(
            'Yes',
            style: GoogleFonts.poppins(
              color: kPrimaryColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          child: Text(
            'No',
            style: GoogleFonts.poppins(
              color: kPrimaryColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showProviderOptionDialog() async {
    DialogBackground(
      barrierColor: Colors.grey.withOpacity(.5),
      blur: 4,
      dismissable: true,
      dialog: AlertDialog(
        content: Text(
          'Pick thumbnail from...',
          style: GoogleFonts.poppins(
            color: kPrimaryColor,
            fontSize: 20,
          ),
        ),
        actions: [
          GFButton(
            blockButton: true,
            onPressed: () async {
              Navigator.of(context).pop();
              var status = await Permission.storage.request();

              if (status == PermissionStatus.granted)
                _pickOrCaptureImage(ImageSource.gallery);
            },
            icon: Icon(Icons.album_outlined, color: Colors.white),
            color: kPrimaryColor,
            textColor: Colors.white,
            text: 'Gallery',
            textStyle: GoogleFonts.poppins(),
          ),
          GFButton(
            blockButton: true,
            onPressed: () async {
              Navigator.of(context).pop();
              Map<Permission, PermissionStatus> status =
                  await [Permission.storage, Permission.camera].request();

              if (status[Permission.storage] == PermissionStatus.granted &&
                  status[Permission.camera] == PermissionStatus.granted)
                _pickOrCaptureImage(ImageSource.camera);
            },
            icon: Icon(Icons.camera_alt_outlined, color: Colors.white),
            color: kPrimaryColor,
            textColor: Colors.white,
            text: 'Camera',
            textStyle: GoogleFonts.poppins(),
          ),
        ],
      ),
    ).show(context);
  }

  Future<void> _pickOrCaptureImage(ImageSource source) async {
    ImagePicker _picker = ImagePicker();
    XFile? _xfile = await _picker.pickImage(source: source);

    if (_xfile != null)
      setState(() {
        _selectedThumbnail = File(_xfile.path);
        _hintText = 'Thumbnail: ${_xfile.path}';
      });
  }

  Future<void> _saveStory() async {
    // Close the previous dialog
    Navigator.of(context, rootNavigator: true).pop();

    if (_titleController!.text.isEmpty || _contentController!.text.isEmpty)
      Utils.showAlertDialog(
        context: context,
        title: 'Create Failed',
        message: 'Please type in the title and the content of the story.',
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: Text(
              'Okay',
              style: GoogleFonts.poppins(
                color: kPrimaryColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      );
    else {
      // Show progress dialog
      Utils.showProgressDialog(
        context: context,
        message: 'Creating story...',
      );

      String _storyId = Uuid().v4();
      String? _thumbnailUrl;
      if (_selectedThumbnail != null)
        _thumbnailUrl = (await StoryService.instance.uploadThumbnail(
          _storyId,
          _selectedThumbnail!,
        ))
            .data;

      Story story = new Story(
        id: _storyId,
        classroom: widget.classroom.id,
        classroomName: widget.classroom.name,
        authorName: await _getAuthorName(widget.classroom.teacher),
        title: _titleController!.text,
        content: _contentController!.text,
        thumbnail: _thumbnailUrl ?? DEFAULT_STORY_THUMBNAIL,
        dateCreated: Jiffy(DateTime.now()).format("MMM dd yyyy hh:mm:ss a"),
      );

      await StoryService.instance.setStory(story);

      // Close the progress dialog
      Navigator.of(context, rootNavigator: true).pop();

      // Refresh story list
      widget.refreshStoryList();

      // Close this form
      Navigator.of(context).pop();

      Utils.showSnackbar(
        context: context,
        message: 'Successfully created a new story.',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    }
  }

  Future<String> _getAuthorName(String id) async {
    Result<List<User>> result = await UserService.instance.getUser('id', id);

    return result.hasError
        ? 'Unknown'
        : '${result.data![0].lastName}, ${result.data![0].firstName.substring(0, 1)}.';
  }
}

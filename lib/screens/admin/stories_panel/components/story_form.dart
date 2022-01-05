import 'dart:io';

import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jiffy/jiffy.dart';
import 'package:ndialog/ndialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../../../../constants.dart';
import '../../../../models/classroom_model.dart';
import '../../../../models/result_model.dart';
import '../../../../models/story_model.dart';
import '../../../../models/user_model.dart';
import '../../../../services/classroom_services.dart';
import '../../../../services/story_services.dart';
import '../../../../services/user_services.dart';
import '../../../../utils/utils.dart';
import 'select_class.dart';

class StoryForm extends StatefulWidget {
  final void Function()? refreshList;
  final Story? story;
  const StoryForm({
    Key? key,
    this.story,
    this.refreshList,
  }) : super(key: key);

  @override
  _StoryFormState createState() => _StoryFormState();
}

class _StoryFormState extends State<StoryForm> {
  TextEditingController? _titleController,
      _thumbnailController,
      _contentController;
  List<Classroom>? classes = [];
  Classroom? _selectedRoom;
  String hintClass = 'Classroom: {Choose classroom...}';
  String selectedClass = 'No selected class...';
  File? _thumbnailImg;
  int _numLines = 0;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
        text: widget.story != null ? widget.story!.title : '');
    _thumbnailController = TextEditingController(
        text: widget.story != null ? widget.story!.thumbnail : '');
    _contentController = TextEditingController(
        text: widget.story != null ? widget.story!.content : '');

    _loadClasses();
  }

  @override
  void dispose() {
    super.dispose();

    _titleController!.dispose();
    _thumbnailController!.dispose();
    _contentController!.dispose();
  }

  Future<void> _loadClasses() async {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      Result<List<Classroom>?> data =
          await ClassroomService.instance.getAllActiveClassrooms();
      print("<Classes: ${!data.hasError}>");

      if (!data.hasError) {
        List<Classroom> _classes = data.data as List<Classroom>;
        String className = '';

        if (widget.story != null)
          for (Classroom _class in _classes)
            if (_class.id == widget.story!.classroom) {
              className = _class.name;
              break;
            }

        setState(() {
          classes = _classes;
          selectedClass =
              widget.story != null ? '$className' : 'No selected class...';
          print(
              "<Selected class: $selectedClass>\n<Classes: ${_classes.length}>");
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_outlined),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.story == null ? 'Add New Story' : 'Edit Story',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: Colors.black87,
                    width: 2,
                  ),
                ),
                elevation: 6,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.86,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 10),
                      _buildTextInput(
                        controller: _titleController!,
                        inputType: TextInputType.name,
                        hint: 'Title',
                        onChanged: (value) {},
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.only(left: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.black87,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _thumbnailController!,
                                enabled: false,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Select thumbnail...',
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
                            TextButton(
                              onPressed: () => _showChoosePhotoDialog(),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  'Choose',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      if (classes != null || classes!.isEmpty) ...[
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black87, width: 2),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  selectedClass,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => SelectClass(
                                      classes: classes!,
                                      onClassSelected: (selectedClassroom) =>
                                          setState(() {
                                        selectedClass = selectedClassroom.name;
                                        _selectedRoom = selectedClassroom;
                                      }),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Select',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(height: 10),
                      Container(
                        height:
                            _numLines < 7 ? 30 * 16 : _numLines.toDouble() * 30,
                        child: TextField(
                          decoration: InputDecoration(
                            focusColor: Colors.black87,
                            hoverColor: Colors.black87,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.black87,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.black87,
                                width: 2,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignLabelWithHint: true,
                            labelText: 'Content of the story',
                            labelStyle: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                            contentPadding: const EdgeInsets.all(14),
                          ),
                          controller: _contentController,
                          cursorColor: Colors.black87,
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
                                TextSelection.collapsed(
                                    offset: prev.baseOffset);
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: MaterialButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              color: Colors.black87,
                              onPressed: () => widget.story == null
                                  ? _showCreateStoryDialog()
                                  : _showUpdateStoryDialog(),
                              child: Text(
                                widget.story != null ? 'Save Story' : 'Create',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    IconData? icon,
    required String hint,
    required ValueChanged<String> onChanged,
    TextInputType? inputType,
    String obscureText = '*',
    bool obscured = false,
  }) {
    return Focus(
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          focusColor: Colors.black87,
          hoverColor: Colors.black87,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.black87,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.black87,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.black87,
              width: 2,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.black87,
              width: 2,
            ),
          ),
          labelText: hint,
          labelStyle: GoogleFonts.poppins(
            fontSize: 18,
            color: Colors.black87,
          ),
          contentPadding: const EdgeInsets.all(14),
          prefixIcon: icon == null ? null : Icon(icon, color: Colors.black87),
          alignLabelWithHint: false,
        ),
        onChanged: (value) => onChanged(value),
        cursorColor: Colors.black87,
        keyboardType: inputType,
        obscureText: obscured,
        obscuringCharacter: obscureText,
      ),
    );
  }

  void _showCreateStoryDialog() {
    Utils.showAlertDialog(
      context: context,
      title: 'Confirm Action',
      message: 'Are you sure you want to create a new story?',
      actions: [
        TextButton(
          onPressed: () => _createOrUpdateStory(),
          child: Text(
            'Yes',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          child: Text(
            'No',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
        ),
      ],
    );
  }

  void _showUpdateStoryDialog() {
    Utils.showAlertDialog(
      context: context,
      title: 'Confirm Action',
      message: 'Are you sure you want to update this story?',
      actions: [
        TextButton(
          onPressed: () => _createOrUpdateStory(),
          child: Text(
            'Yes',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          child: Text(
            'No',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
        ),
      ],
    );
  }

  void _showChoosePhotoDialog() {
    DialogBackground(
      barrierColor: Colors.grey.withAlpha(0x80),
      blur: 4,
      dismissable: true,
      dialog: AlertDialog(
        content: Text(
          'Pick thumbnail image from one of the following providers...',
          style: GoogleFonts.poppins(),
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
            color: Colors.black87,
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
            color: Colors.black87,
            textColor: Colors.white,
            text: 'Camera',
            textStyle: GoogleFonts.poppins(),
          ),
        ],
      ),
    ).show(context);
  }

  Future<void> _createOrUpdateStory() async {
    Navigator.of(context, rootNavigator: true).pop();

    String _title = _titleController!.text;
    String _thumbnail = _thumbnailController!.text;
    String _content = _contentController!.text;

    if (_title.isEmpty || _thumbnail.isEmpty || _content.isEmpty)
      Utils.showSnackbar(
        context: context,
        message: 'Please fill in all the required fields!',
      );
    else {
      Utils.showProgressDialog(
        context: context,
        message:
            widget.story != null ? 'Updating story...' : 'Creating story...',
      );

      String? _thumnailUrl;
      String uid = widget.story != null ? widget.story!.id : Uuid().v4();
      if (_thumbnailImg != null)
        _thumnailUrl =
            (await StoryService.instance.uploadThumbnail(uid, _thumbnailImg!))
                .data;

      Story story = Story(
        id: uid,
        classroom: _selectedRoom!.id,
        classroomName: _selectedRoom!.name,
        authorName: widget.story != null
            ? widget.story!.authorName
            : await _getAuthorName(_selectedRoom!.teacher),
        title: _title,
        content: _content,
        thumbnail: _thumnailUrl ??
            (widget.story == null
                ? DEFAULT_STORY_THUMBNAIL
                : widget.story!.thumbnail),
        dateCreated: widget.story != null
            ? widget.story!.dateCreated
            : Jiffy(DateTime.now()).format("MMM dd yyyy hh:mm a"),
      );

      await StoryService.instance.setStory(story);

      Navigator.of(context, rootNavigator: true).pop();
      widget.refreshList!();

      Utils.showSnackbar(
        context: context,
        message: 'Story has been saved successfully!',
      );

      Navigator.of(context).pop();
    }
  }

  Future<void> _pickOrCaptureImage(ImageSource source) async {
    ImagePicker _picker = ImagePicker();
    XFile? _xfile = await _picker.pickImage(source: source);

    if (_xfile != null)
      setState(() {
        _thumbnailImg = File(_xfile.path);
        _thumbnailController!.text = 'Thumbnail: ${_thumbnailImg!.path}';
      });
  }

  Future<String> _getAuthorName(String id) async {
    Result<List<User>> result = await UserService.instance.getUser('id', id);

    return result.hasError
        ? 'Unknown'
        : '${result.data![0].lastName}, ${result.data![0].firstName.substring(0, 1)}.';
  }
}

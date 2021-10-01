import 'dart:io';

import 'package:dbcrypt/dbcrypt.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache/flutter_cache.dart' as Cache;
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ndialog/ndialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../constants.dart';
import '../../../../models/user_model.dart';
import '../../../../providers/temp_variables_provider.dart';
import '../../../../services/user_services.dart';
import '../../../../utils/utils.dart';

class SettingsBody extends StatefulWidget {
  final User? user;

  const SettingsBody({ 
    Key? key, 
    this.user,
  }) : super(key: key);

  @override
  _SettingsBodyState createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<SettingsBody> {
  TextEditingController? _firstNameController, 
                         _lastNameController, 
                         _emailController, 
                         _genderController, 
                         _passwordController;
  File? _profileImg;
  bool hasPasswordChanges = false;

  @override
  void initState() {
    super.initState();

    _firstNameController = TextEditingController(text: widget.user!.firstName);
    _lastNameController = TextEditingController(text: widget.user!.lastName);
    _emailController = TextEditingController(text: widget.user!.email);
    _genderController = TextEditingController(text:  widget.user!.gender);
    _passwordController = TextEditingController(text: '--------');
  }

  @override
  void dispose() {
    super.dispose();

    _firstNameController!.dispose();
    _lastNameController!.dispose();
    _emailController!.dispose();
    _genderController!.dispose();
    _passwordController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Center(
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
                        SizedBox(height: 20),
                        Stack(
                          children: [
                            _profileImg != null
                              ? CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  backgroundImage: FileImage(_profileImg!),
                                  radius: 50,
                                )
                              : CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  backgroundImage: NetworkImage(widget.user == null
                                    ? "https://www.stevefarber.com/wp-content/uploads/2019/01/man-avatar-placeholder.png"
                                    : widget.user!.photo,
                                ),
                                radius: 50,
                              ),
                            Positioned(
                              bottom: -5,
                              right: -26,
                              child: MaterialButton(
                                shape: CircleBorder(),
                                padding: const EdgeInsets.all(8),
                                color: Colors.black87,
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                onPressed: () => _showChoosePhotoDialog(),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 40),
                        _buildTextInput(
                          controller: _firstNameController!, 
                          icon: Icons.person_outline_outlined,
                          inputType: TextInputType.name, 
                          hint: 'Firstname', 
                          onChanged: (value) {},
                        ),
                        SizedBox(height: 10),
                        _buildTextInput(
                          controller: _lastNameController!, 
                          icon: Icons.person_outline_outlined, 
                          inputType: TextInputType.name, 
                          hint: 'Lastname', 
                          onChanged: (value) {},
                        ),
                        SizedBox(height: 10),
                        _buildTextInput(
                          controller: _emailController!, 
                          icon: Icons.email_outlined,
                          inputType: TextInputType.emailAddress, 
                          hint: 'Email Address', 
                          onChanged: (value) {},
                        ),
                        SizedBox(height: 10),
                        _buildTextInput(
                          controller: _genderController!, 
                          icon: Icons.male_outlined,
                          inputType: TextInputType.text, 
                          hint: 'Gender', 
                          onChanged: (value) {},
                        ),
                        SizedBox(height: 10),
                        _buildTextInput(
                          controller: _passwordController!, 
                          icon: Icons.password_outlined,
                          obscured: true,
                          hint: 'Password', 
                          onChanged: (value) {
                            hasPasswordChanges = value != '---------' || value.isNotEmpty;
                          },
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: MaterialButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                color: Colors.black87,
                                onPressed: () => _showsaveChangesDialog(),
                                child: Text(
                                  'Save Settings',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required IconData icon,
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
          prefixIcon: Icon(icon, color: Colors.black87),
          alignLabelWithHint: false,
        ),
        onChanged: (value) => onChanged(value),
        cursorColor: Colors.black87,
        keyboardType: inputType,
        obscureText: obscured,
        obscuringCharacter: obscureText,
      ),
      onFocusChange: (hasFocus) {
        if(obscured) {
          controller.text = hasPasswordChanges
            ? controller.text
            : hasFocus 
              ? '' 
              : widget.user != null 
                ? '--------'
                : '';
        }
      },
    );
  }

  void _showsaveChangesDialog() {
    Utils.showAlertDialog(
      context: context, 
      title: 'Confirm Action',
      message: 'Are you sure you want to save these changes?', 
      actions: [
        TextButton(
          onPressed: () => _saveChanges(), 
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
          'Pick profile image from one of the following providers...',
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
                await [
                  Permission.storage,
                  Permission.camera
                ].request();

              if (status[Permission.storage] == PermissionStatus.granted && status[Permission.camera] == PermissionStatus.granted)
                _pickOrCaptureImage(ImageSource.gallery);
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

  Future<void> _saveChanges() async {
    Navigator.of(context, rootNavigator: true).pop();

    String _firstname = _firstNameController!.text;
    String _lastname = _lastNameController!.text;
    String _email = _emailController!.text;
    String _gender = _genderController!.text;
    String _password = _passwordController!.text;

    if(_firstname.isEmpty || _lastname.isEmpty || _email.isEmpty || _gender.isEmpty || _password.isEmpty)
      Utils.showSnackbar(
        context: context, 
        message: 'Please fill in all the required fields!',
      );
    else if(!EmailValidator.validate(_email))
      Utils.showSnackbar(
        context: context, 
        message: 'Please enter a valid email address!',
      );
    else {
      Utils.showProgressDialog(
        context: context, 
        message: 'Saving changes...',
      );

      String? _photoUrl;
      String uid = widget.user != null ? widget.user!.id : Uuid().v4();
      if(_profileImg != null)
        _photoUrl = (await UserService.instance.uploadPhoto(uid, _profileImg!)).data;

      User user = User(
        id: uid, 
        firstName: _firstname, 
        lastName: _lastname, 
        gender: _gender, 
        email: _email, 
        password: _password == '--------' 
          ? widget.user!.password
          : DBCrypt().hashpw(_password, DBCrypt().gensalt()), 
        photo: widget.user != null 
          ? _photoUrl ?? widget.user!.photo
          : _photoUrl ?? 'https://www.stevefarber.com/wp-content/uploads/2019/01/man-avatar-placeholder.png',
        type: 2,
      );

      await UserService.instance.setUser(user);
      await Cache.write('user', user.toJson());

      Navigator.of(context, rootNavigator: true).pop();
      Provider.of<TempVariables>(context, listen: false).onSettingsUpdated!();

      Utils.showSnackbar(
        context: context, 
        message: 'Changes has been saved succesfully!',
      );
    }
  }

  Future<void> _pickOrCaptureImage(ImageSource source) async {
    ImagePicker _picker = ImagePicker();
    XFile? _xfile = await _picker.pickImage(source: source);

    if (_xfile != null)
      setState(() {
        _profileImg = File(_xfile.path);
      });
  }
}
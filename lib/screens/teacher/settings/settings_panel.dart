import 'dart:io';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
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
import 'package:shimmer/shimmer.dart';

import '../../../auth/auth.dart';
import '../../../constants.dart';
import '../../../models/user_model.dart';
import '../../../providers/temp_variables_provider.dart';
import '../../../services/user_services.dart';
import '../../welcome/welcome_screen.dart';

class SettingsPanel extends StatefulWidget {
  const SettingsPanel();

  @override
  _SettingsPanelState createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> with SingleTickerProviderStateMixin {
  ScrollController _scrollController = ScrollController();
  TextEditingController _firstNameController = TextEditingController(),
                        _lastNameController = TextEditingController(),
                        _emailController = TextEditingController(),
                        _passwordController = TextEditingController(),
                        _schoolNameController = TextEditingController(),
                        _schoolAddressController = TextEditingController();
  User? _user;
  File? _profileImg;

  String _message = '';
  bool _editFirstName = false,
       _editLastName = false,
       _editEmail = false,
       _editPassword = false,
       _editSchoolName = false,
       _editSchoolAddress = false,
       _isEditing = false,
       _isSaving = false,
       _hasError = false;

  @override
  void initState() {
    super.initState();

    _loadUserData();

    _firstNameController.text = _user!.firstName;
    _lastNameController.text = _user!.lastName;
    _emailController.text = _user!.email;
    _passwordController.text = '--------';
    _schoolNameController.text = _user!.schoolName;
    _schoolAddressController.text = _user!.schoolAddress;
  }

  @override
  void dispose() {
    super.dispose();

    _user = null;
    _scrollController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _schoolNameController.dispose();
    _schoolAddressController.dispose();
  }

  Future<void> _loadUserData() async {
    Map<String, dynamic> json = await Cache.load('user', <String, dynamic>{});
    _user = User.fromJson(json);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: ConnectivityWidgetWrapper(
          disableInteraction: true,
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        child: Container(
                          child: Icon(
                            Icons.arrow_back_ios_new_outlined,
                            color: Colors.black,
                          ),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                            border: Border.all(
                              color: kPrimaryLightColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'My Account',
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      _isEditing 
                        ? IconButton(
                            tooltip: 'Save Changes',
                            icon: Icon(
                              Icons.save_outlined,
                              color: Colors.black,
                              size: 30,
                            ),
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                _isSaving = true;
                              });

                              _saveChanges();
                            },
                          )
                        : _isSaving 
                            ? CircularProgressIndicator(
                                color: kPrimaryColor,
                              )
                            : Container(),
                    ],
                  ),
                  SizedBox(height: 40),
                  Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(right: 16),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Stack(
                                children: [
                                  SizedBox(
                                    width: 88,
                                    height: 88,
                                    child: Shimmer.fromColors(
                                      child: Container(
                                        width: 88,
                                        height: 88,
                                        color: Colors.white,
                                      ), 
                                      baseColor: kBaseColor, 
                                      highlightColor: kHighlightColor,
                                    ),
                                  ),
                                  _profileImg == null
                                    ? FadeInImage.memoryNetwork(
                                      placeholder: kTransparentImage, 
                                      image: _user!.photo,
                                      width: 88,
                                      height: 88,
                                      fit: BoxFit.cover,
                                    )
                                    : FadeInImage(
                                      placeholder: MemoryImage(kTransparentImage), 
                                      image: FileImage(_profileImg!),
                                      width: 88,
                                      height: 88,
                                      fit: BoxFit.cover,
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 12,
                            child: InkWell(
                              onTap: () async {
                                DialogBackground(
                                  barrierColor: Colors.grey.withOpacity(.5),
                                  blur: 4,
                                  dismissable: true,
                                  dialog: AlertDialog(
                                    content: Text(
                                      'Pick your profile image from...', 
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
                                            await [
                                              Permission.storage,
                                              Permission.camera
                                            ].request();
    
                                          if (status[Permission.storage] == PermissionStatus.granted && status[Permission.camera] == PermissionStatus.granted)
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
                              },
                              borderRadius: BorderRadius.all(Radius.circular(50)),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: Colors.grey.shade100,
                                    width: 3,
                                  ),
                                  color: kPrimaryColor,
                                ),
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.mode_edit_outline,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.watch<TempVariables>().tempFirstName ?? _user!.firstName,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ), 
                          SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: kPrimaryColor,
                                width: 2.8,
                              ),
                              color: Colors.white,
                            ),
                            child: Text(
                              'TEACHER',
                              style: GoogleFonts.poppins(
                                color: kPrimaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  _hasError 
                    ? _showError()
                    : Container(),
                  SizedBox(height: 40),
                  Card(
                    elevation: 3,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _labeledInputField(
                            label: 'First Name',
                            enabled: _editFirstName,
                            controller: _firstNameController,
                            onEditPressed: () {
                              setState(() {
                                _editFirstName = !_editFirstName;

                                if(!_editFirstName)
                                {
                                  context.read<TempVariables>().setTempFirstName(_user!.firstName);
                                  
                                  _firstNameController.text = _user!.firstName;
                                  _firstNameController.selection = TextSelection.collapsed(offset: _user!.firstName.length);
                                }

                                if(_isEditing)
                                  _isEditing = !_isEditing;
                              });
                            },
                            onChanged: (string) {
                              TextSelection prev = _firstNameController.selection;
                              context.read<TempVariables>().setTempFirstName(string);
                              
                              _firstNameController.text = string;
                              _firstNameController.selection = TextSelection.collapsed(offset: prev.baseOffset);

                              if(!_isEditing)
                                setState(() {
                                  _isEditing = !_isEditing;
                                });
                            },
                          ),
                          _labeledInputField(
                            label: 'Last Name',
                            enabled: _editLastName,
                            controller: _lastNameController, 
                            onEditPressed: () {
                              setState(() {
                                _editLastName = !_editLastName;

                                if(!_editLastName)
                                  _lastNameController.text = _user!.lastName;

                                if(_isEditing)
                                  _isEditing = !_isEditing;
                              });
                            },
                            onChanged: (string) {
                              if(!_isEditing)
                                setState(() {
                                  _isEditing = !_isEditing;
                                });
                            },
                          ),
                          _labeledInputField(
                            label: 'Email Address', 
                            enabled: _editEmail,
                            controller: _emailController, 
                            onEditPressed: () {
                              setState(() {
                                _editEmail = !_editEmail;

                                if(!_editEmail)
                                  _emailController.text = _user!.email;

                                if(_isEditing)
                                  _isEditing = !_isEditing;
                              });
                            },
                            onChanged: (string) {
                              if(!_isEditing)
                                setState(() {
                                  _isEditing = !_isEditing;
                                });
                            },
                          ),
                          _labeledInputField(
                            label: 'Password', 
                            enabled: _editPassword,
                            controller: _passwordController, 
                            obscuredText: true,
                            onEditPressed: () {
                              setState(() {
                                _editPassword = !_editPassword;

                                if(!_editPassword)
                                  _passwordController.text = '--------';
                                else
                                  _passwordController.text = '';

                                if(_isEditing)
                                  _isEditing = !_isEditing;
                              });
                            },
                            onChanged: (string) {
                              if(!_isEditing)
                                setState(() {
                                  _isEditing = !_isEditing;
                                });
                            },
                          ),
                          _labeledInputField(
                            label: 'School Name', 
                            enabled: _editSchoolName,
                            controller: _schoolNameController,
                            onEditPressed: () {
                              setState(() {
                                _editSchoolName = !_editSchoolName;

                                if(!_editSchoolName)
                                  _schoolNameController.text = _user!.schoolName;

                                if(_isEditing)
                                  _isEditing = !_isEditing;
                              });
                            }, 
                            onChanged: (string) {
                              if(!_isEditing)
                                setState(() {
                                  _isEditing = !_isEditing;
                                });
                            },
                          ),
                          _labeledInputField(
                            label: 'School Address', 
                            enabled: _editSchoolAddress,
                            controller: _schoolAddressController,
                            onEditPressed: () {
                              setState(() {
                                _editSchoolAddress = !_editSchoolAddress;

                                if(!_editSchoolAddress)
                                  _schoolAddressController.text = _user!.schoolAddress;

                                if(_isEditing)
                                  _isEditing = !_isEditing;
                              });
                            }, 
                            onChanged: (string) {
                              if(!_isEditing)
                                setState(() {
                                  _isEditing = !_isEditing;
                                });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  MaterialButton(
                    minWidth: MediaQuery.of(context).size.width * 0.89,
                    height: 50,
                    color: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onPressed: () => _signOut(),
                    child: Text(
                      'Sign Out',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  MaterialButton(
                    minWidth: MediaQuery.of(context).size.width * 0.89,
                    height: 50,
                    color: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onPressed: () => _deleteAccount(),
                    child: Text(
                      'Delete Account',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        letterSpacing: 2,
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

  Future _pickOrCaptureImage(ImageSource source) async {
    ImagePicker _picker = ImagePicker();
    XFile? _xfile = await _picker.pickImage(source: source);

    if (_xfile != null)
      setState(() {
        _profileImg = File(_xfile.path);
        _isEditing = true;
      });
  }

  Widget _labeledInputField({
    required String label, 
    required TextEditingController controller, 
    required void Function(String string) onChanged,
    required void Function() onEditPressed,
    required bool enabled,
    bool obscuredText = false,
  }) {
    return Container(
      padding: const EdgeInsets.only(bottom: 5),
      height: 66,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              cursorColor: kPrimaryColor,
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 16.8,
                fontWeight: FontWeight.bold,
              ),
              autocorrect: false,
              enableSuggestions: false,
              autofillHints: null,
              obscureText: obscuredText,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
                border: InputBorder.none,
                enabled: enabled,
              ),
            ),
          ),
          SizedBox(width: 10),
          TextButton(
            onPressed: onEditPressed,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(enabled ? Colors.red : kPrimaryLightColor),
            ),
            child: Text(
              enabled ? 'Cancel' : 'Edit',
              style: GoogleFonts.poppins(
                color: enabled ? Colors.white : kPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _saveChanges() async {
    String _firstName = _firstNameController.text;
    String _lastName = _lastNameController.text;
    String _email = _emailController.text;
    String _password = _passwordController.text == '--------' 
      ? _user!.password 
      : DBCrypt().hashpw(_passwordController.text, DBCrypt().gensalt());
    String _schoolName = _schoolNameController.text;
    String _schoolAddress = _schoolAddressController.text;

    // Hide error
    if(_hasError)
      setState(() {
        _hasError = false;
        _message = '';
      });

    if(_firstName.isEmpty || _lastName.isEmpty || _email.isEmpty || _password.isEmpty || _schoolName.isEmpty || _schoolAddress.isEmpty)
      setState(() {
        _hasError = true;
        _message = MESSAGES['users']!['empty_field']!;
      });
    else if(!EmailValidator.validate(_email))
      setState(() {
        _hasError = true;
        _message = MESSAGES['email']!['invalid']!;
      });
    else {
      String? _photoUrl;
      if(_profileImg != null)
        _photoUrl = (await UserService.instance.uploadPhoto(_user!.id, _profileImg!)).data;

      Map<String, dynamic> data = await Cache.load('user', <String, dynamic>{});
      Map<String, dynamic> json = _user!.toJson();
      json['first_name'] = _firstName;
      json['last_name'] = _lastName;
      json['email'] = _email;
      json['password'] = _password;
      json['school_name'] = _schoolName;
      json['school_address'] = _schoolAddress;
      json['photo'] = _photoUrl ?? _user!.photo;

      data['first_name'] = _firstName;
      data['last_name'] = _lastName;
      data['email'] = _email;
      data['password'] = _password;
      data['school_name'] = _schoolName;
      data['school_address'] = _schoolAddress;
      data['photo'] = _photoUrl ?? _user!.photo;

      await UserService.instance.setUser(User.fromJson(json));
      await Cache.write('user', data);

      setState(() {
        _isSaving = false;
        _hasError = false;
        _message = '';
      });

      return true;
    }

    return false;
  }

  Future _signOut() async {
    await Auth.instance.signOutUsingFirebaseAuth();
    Navigator.of(context).pop(); // Close Settings
    Navigator.of(context).pop(); // Close Main UI
    Cache.clear();               // Clear cache
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WelcomeScreen(),
      ),
    );
  }

  Future _deleteAccount() async {
    // TODO: Show alert dialog before deleting account
  }

  Widget _showError() {
    _scrollController.animateTo(
      0.0, 
      duration: Duration(microseconds: 800), 
      curve: Curves.fastOutSlowIn,
    );

    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 5,),
          Text(
            _message, 
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, 
              color: Colors.red,
            ),
          ),
          SizedBox(height: 5,)
        ],
      ),
    );
  }
}

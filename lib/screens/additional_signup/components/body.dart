import 'dart:io';

import 'package:dbcrypt/dbcrypt.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter_cache/flutter_cache.dart' as Cache;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_radio_group/flutter_radio_group.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ndialog/ndialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../../../auth/auth.dart';
import '../../../components/rounded_button.dart';
import '../../../components/rounded_input_field.dart';
import '../../../components/rounded_password_field.dart';
import '../../../constants.dart';
import '../../../models/result_model.dart';
import '../../../models/user_model.dart';
import '../../../services/user_services.dart';
import '../../teacher/teacher_panel.dart';
import 'background.dart';

class Body extends StatefulWidget {
  final UserCredential? credential;
  final Map<String, dynamic>? data;
  final bool usingSocMed;

  const Body(this.credential, this.data, this.usingSocMed);

  @override
  _BodyState createState() => _BodyState(credential, data, usingSocMed);
}

class _BodyState extends State<Body> with TickerProviderStateMixin {
  final UserCredential? credential;
  final Map<String, dynamic>? data;
  final bool usingSocMed;

  _BodyState(this.credential, this.data, this.usingSocMed);

  ScrollController _scrollController = ScrollController();
  List<String> _genders = ['Male', 'Female', 'Others'];
  List<String> _account = ['Parent', 'Teacher'];
  List<String> _types = ['Public', 'Private'];

  String _message = '';
  bool _hasError = false;
  bool _isSigningUp = false;

  int _accountIndex = 0;
  int _genderIndex = 0;
  int _typeOfSchool = 0;

  List<String>? _nameParts;
  File? _profileImg;
  String? _profileSrc, _firstName, _lastName, _email, _password, _childName, _childAge, _schoolName, _schoolAddress;
  bool _fNChanged = false, 
       _lNChanged = false, 
       _emailChanged = false,
       _passChanged = false;

  @override
  void dispose() {
    super.dispose();

    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _nameParts = credential != null ? credential!.user!.displayName!.split(' ') : null;
    _profileSrc = credential?.user?.photoURL;

    _fNChanged = _nameParts != null || _firstName != null;
    _lNChanged = _nameParts != null || _lastName != null;
    _emailChanged = (data != null || credential != null || _email != null);
    _passChanged = (_password != null && _password!.isNotEmpty);

    return WillPopScope(
      onWillPop: () async {
        DialogBackground(
          barrierColor: Colors.grey.withOpacity(.5),
          blur: 4,
          dismissable: true,
          dialog: AlertDialog(
            content: Text(
              'Are you sure you want to cancel creating your account?',
                style: GoogleFonts.delius(color: kPrimaryColor)
            ),
            actions: [
              GFButton(
                onPressed: () async {
                  try {
                    if(credential != null)
                    {
                      Auth auth = Auth.instance;
                      Map<String, dynamic> data = await Cache.load('user', <String, dynamic>{});
                      bool isGoogle = data['isGoogle'] as bool;

                      await auth.reauthenticateUser(isGoogle);
                      await auth.deleteCurrentUser();

                      isGoogle ? GoogleSignIn().signOut() : FacebookAuth.instance.logOut();

                      Cache.clear();
                    }
                  } catch(e) {
                    print("Delete Failed: $e");
                  }

                  Navigator.of(context).pop(); // Close dialog first
                  Navigator.of(context).pop(); // Then close this layout
                },
                color: kPrimaryColor,
                textColor: Colors.white,
                text: 'Yes',
                textStyle: GoogleFonts.delius(),
              ),
              GFButton(
                onPressed: () => Navigator.of(context).pop(),
                color: kPrimaryColor,
                textColor: Colors.white,
                text: 'No',
                textStyle: GoogleFonts.delius(),
              ),
            ],
          ),
        ).show(context);
        return true;
      },
      child: Background(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                height: 10,
              ),
              Text(
                'Finish your account',
                style: GoogleFonts.delius(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30,
              ),
              Stack(
                children: [
                  _profileImg != null
                      ? CircleAvatar(
                          backgroundImage: FileImage(_profileImg as File),
                          radius: 78,
                          backgroundColor: kPrimaryLightColor,
                        )
                      : CircleAvatar(
                          backgroundImage: _profileSrc != null
                              ? NetworkImage(_profileSrc as String)
                              : null,
                          radius: 78,
                          backgroundColor: kPrimaryLightColor,
                        ),
                  Positioned(
                    bottom: 0,
                    right: -10,
                    child: MaterialButton(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(12),
                        color: kPrimaryColor,
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white70,
                          size: 24,
                        ),
                        onPressed: () async {
                          DialogBackground(
                            barrierColor: Colors.grey.withOpacity(.5),
                            blur: 4,
                            dismissable: true,
                            dialog: AlertDialog(
                              content: Text(
                                'Pick your profile image from...', 
                                style: GoogleFonts.delius(
                                  color: kPrimaryColor,
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
                                  textStyle: GoogleFonts.delius(),
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
                                  textStyle: GoogleFonts.delius(),
                                ),
                              ],
                            ),
                          ).show(context);
                        },
                      ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              _hasError
                  ? _showError(_message)
                  : Container(
                      width: 0,
                      height: 0,
                    ),
              _hasError
                  ? SizedBox(height: 5)
                  : Container(
                      width: 0,
                      height: 0,
                    ),
              RoundedInputField(
                  defaultValue: _nameParts != null && _firstName == null ? _nameParts![0] : _firstName,
                  icon: Icons.person_outline_outlined,
                  hintText: 'First name',
                  onChanged: (value) {
                    _firstName = value;
                  }),
              RoundedInputField(
                  defaultValue: (_nameParts != null && _nameParts!.length > 1 && _lastName == null)
                      ? _nameParts![_nameParts!.length - 1]
                      : _lastName,
                  icon: Icons.person_outline_outlined,
                  hintText: 'Last name',
                  onChanged: (value) {
                    _lastName = value;
                  }),
              RoundedInputField(
                  defaultValue: credential != null
                      ? credential!.user!.email
                      : data != null && _email == null
                          ? data!['email']
                          : _email,
                  icon: Icons.mail_outline,
                  hintText: 'Email address',
                  onChanged: (value) {
                    _email = value;
                  }),
              RoundedPasswordField(
                  defaultValue: data != null && _password == null ? data!['password'] : _password,
                  icon: Icons.vpn_key_outlined,
                  onChanged: (value) {
                    _password = value;
                  }),
              _accountIndex == 0
                ? RoundedInputField(
                  defaultValue: _childName,
                  icon: Icons.child_friendly_outlined,
                  hintText: 'Child\'s name',
                  onChanged: (value) {
                    _childName = value;
                  })
                : Container(),
              _accountIndex == 0
                ? RoundedInputField(
                  defaultValue: _childAge,
                  icon: Icons.child_friendly_outlined,
                  hintText: 'Child\'s age',
                  onChanged: (value) {
                    _childAge = value;
                  })
                : Container(),
              _accountIndex == 1
                ? RoundedInputField(
                  defaultValue: _schoolName,
                  icon: Icons.school_outlined,
                  hintText: 'Name of School',
                  onChanged: (value) {
                    _schoolName = value;
                  })
                : Container(),
              _accountIndex == 1
                ? RoundedInputField(
                  defaultValue: _schoolAddress,
                  icon: Icons.my_location_outlined,
                  hintText: 'Address of school',
                  onChanged: (value) {
                    _schoolAddress = value;
                  })
                : Container(),
              _accountIndex == 1 
                ? SizedBox(
                    height: 10,
                  ) 
                : Container(),
              _accountIndex == 1
                ? Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: FlutterRadioGroup(
                      titles: _types,
                      label: 'Type of School',
                      labelStyle:
                          GoogleFonts.delius(color: kPrimaryColor, fontSize: 18),
                      titleStyle:
                          GoogleFonts.delius(color: kPrimaryColor, fontSize: 18),
                      defaultSelected: _typeOfSchool,
                      activeColor: kPrimaryColor,
                      orientation: RGOrientation.HORIZONTAL,
                      onChanged: (index) {
                        _typeOfSchool = index as int;
                      },
                    ),
                  )
                : Container(),
              SizedBox(
                height: 10,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: FlutterRadioGroup(
                  titles: _genders,
                  label: 'Gender',
                  labelStyle:
                      GoogleFonts.delius(color: kPrimaryColor, fontSize: 18),
                  titleStyle:
                      GoogleFonts.delius(color: kPrimaryColor, fontSize: 18),
                  defaultSelected: _genderIndex,
                  activeColor: kPrimaryColor,
                  orientation: RGOrientation.HORIZONTAL,
                  onChanged: (index) {
                    _genderIndex = index as int;
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: FlutterRadioGroup(
                  titles: _account,
                  label: 'Account Type',
                  labelStyle:
                      GoogleFonts.delius(color: kPrimaryColor, fontSize: 18),
                  titleStyle:
                      GoogleFonts.delius(color: kPrimaryColor, fontSize: 18),
                  defaultSelected: _accountIndex,
                  activeColor: kPrimaryColor,
                  orientation: RGOrientation.HORIZONTAL,
                  onChanged: (index) {
                    setState(() {
                      _accountIndex = index as int;
                    });
                  },
                ),
              ),
              _actions()
            ],
          ),
        ),
      ),
    );
  }

  Widget _actions() {
    return _isSigningUp
        ? FutureBuilder(
            future: _signUp(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) 
                return Container();
              else if(snapshot.connectionState == ConnectionState.done && !snapshot.hasData)
                return _actions();

              return Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: CircularProgressIndicator(
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  )
                ],
              );
            },
          )
        : RoundedButton(
            text: 'CONTINUE',
            press: () {
              setState(() {
                _isSigningUp = true;
              });
            });
  }

  Widget _showError(String message) {
    _scrollController.animateTo(
      0.0, 
      duration: Duration(milliseconds: 800), 
      curve: Curves.fastOutSlowIn,
    );

    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 5,
          ),
          Text(
            message,
            style: GoogleFonts.delius(
                fontWeight: FontWeight.bold, color: Colors.red),
          ),
          SizedBox(
            height: 5,
          )
        ],
      ),
    );
  }

  Future _pickOrCaptureImage(ImageSource source) async {
    ImagePicker _picker = ImagePicker();
    XFile? _xfile = await _picker.pickImage(source: source);

    if (_xfile != null)
      setState(() {
        _profileImg = File(_xfile.path);
      });
  }

  Future<Result?> _signUp() async {
    if (!_fNChanged || !_lNChanged || !_emailChanged || !_passChanged)
      setState(() {
        _hasError = true;
        _message = MESSAGES['users']!['empty_field'] as String;
        _isSigningUp = false;
        print('Empty fields');
      });
    else if(_email != null && !EmailValidator.validate(_email as String))
      setState(() {
        _hasError = true;
        _message = MESSAGES['email']!['invalid'] as String;
        _isSigningUp = false;
        print('Invalid email address format');
      });
    else {
      Result<List<User>> users = await UserService.instance.getUser('email', _email);
      print('Check for existing email, done!');
      print('Users: ${users.data}');

      if (users.hasError) {
        print('Email address is available for registration');

        String _id = Uuid().v4();
        _password = DBCrypt().hashpw(_password as String, DBCrypt().gensalt());

        if (_profileImg != null) {
          Result<String> photoUrl = await UserService.instance.uploadPhoto(_id, _profileImg as File);
          _profileSrc = photoUrl.data;
        }

        User user = User(
          id: _id,
          firstName: _firstName as String,
          lastName: (_lastName != null && _nameParts == null) ? _lastName as String : _nameParts![_nameParts!.length-1],
          email: (_email != null && (data != null || credential != null)) ? _email as String : (data != null) ? data!['email'] : credential!.user!.email,
          gender: _genders[_genderIndex],
          password: _password as String,
          schoolName: _schoolName != null && _accountIndex == 1 ? _schoolName as String : '',
          schoolAddress: _schoolAddress != null && _accountIndex == 1 ? _schoolAddress as String : '',
          schoolType: _accountIndex == 1 ? _types[_typeOfSchool] : '',
          childName: _childName != null && _accountIndex == 0 ? _childName as String : '',
          childAge: _childAge != null && _accountIndex == 0 ? int.parse(_childAge as String) : 0,
          photo: _profileSrc as String,
          type: _accountIndex,
          isDeleted: false
        );

        await UserService.instance.setUser(user);
        print('User saved');

        Map<String, dynamic> oldData = await Cache.load('user');
        Map<String, dynamic> newData = user.toJson();
        newData['isGoogle'] = oldData['isGoogle'];
        await Cache.write('user', newData);
        
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => _accountIndex == 1 
            ? TeacherPanel(user) 
            : Container(),
          ),
        );

        return Result();
      } else
        setState(() {
          _isSigningUp = false;
          _hasError = true;
          _message = MESSAGES['email']!['exist'] as String;
          print('Email address already exist');
        });

      return null;
    }
  }
}

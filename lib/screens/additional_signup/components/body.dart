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
import '../../../enums/role_enum.dart';
import '../../../models/result_model.dart';
import '../../../models/user_model.dart';
import '../../../services/user_services.dart';
import '../../../utils/utils.dart';
import '../../parent/parent_panel.dart';
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
  List<String> _genders = ['Male', 'Female'];
  List<String> _account = ['Parent', 'Teacher'];
  List<String> _types = ['Public', 'Private'];

  bool _isSigningUp = false;
  bool _setupDone = false;

  int _accountIndex = 0;
  int _genderIndex = 0;
  int _typeOfSchool = 0;

  List<String>? _nameParts;
  File? _profileImg;
  String? _profileSrc,
      _firstName,
      _lastName,
      _email,
      _password,
      _childName,
      _childAge,
      _schoolName,
      _schoolAddress;

  @override
  void dispose() {
    super.dispose();

    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Setup Done: $_setupDone');
    if (!_setupDone) {
      _nameParts =
          credential != null ? credential!.user!.displayName!.split(' ') : null;
      _profileSrc = credential?.user?.photoURL;

      _firstName = credential != null ? _nameParts![0] : '';
      _lastName = credential != null
          ? (_nameParts!.length > 1)
              ? _nameParts![1]
              : ''
          : '';
      _email = credential != null ? credential!.user!.email : data!['email'];
      _password = data != null ? data!['password'] : '';

      _setupDone = true;
    }

    return WillPopScope(
      onWillPop: () async {
        DialogBackground(
          barrierColor: Colors.grey.withOpacity(.5),
          blur: 4,
          dismissable: true,
          dialog: AlertDialog(
            content: Text(
                'Are you sure you want to cancel creating your account?',
                style: GoogleFonts.poppins(color: kPrimaryColor)),
            actions: [
              GFButton(
                onPressed: () async {
                  try {
                    if (credential != null) {
                      Auth auth = Auth.instance;
                      Map<String, dynamic> data =
                          await Cache.load('user', <String, dynamic>{});
                      bool isGoogle = data['isGoogle'] as bool;

                      await auth.reauthenticateUser(isGoogle);
                      await auth.deleteCurrentUser();

                      isGoogle
                          ? GoogleSignIn().signOut()
                          : FacebookAuth.instance.logOut();

                      Cache.clear();
                    }
                  } catch (e) {
                    print("Delete Failed: $e");
                  }

                  Navigator.of(context).pop(); // Close dialog first
                  Navigator.of(context).pop(); // Then close this layout
                },
                color: kPrimaryColor,
                textColor: Colors.white,
                text: 'Yes',
                textStyle: GoogleFonts.poppins(),
              ),
              GFButton(
                onPressed: () => Navigator.of(context).pop(),
                color: kPrimaryColor,
                textColor: Colors.white,
                text: 'No',
                textStyle: GoogleFonts.poppins(),
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
                style: GoogleFonts.poppins(
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
                              style: GoogleFonts.poppins(
                                color: kPrimaryColor,
                              ),
                            ),
                            actions: [
                              GFButton(
                                blockButton: true,
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  var status =
                                      await Permission.storage.request();

                                  if (status == PermissionStatus.granted)
                                    _pickOrCaptureImage(ImageSource.gallery);
                                },
                                icon: Icon(Icons.album_outlined,
                                    color: Colors.white),
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

                                  if (status[Permission.storage] ==
                                          PermissionStatus.granted &&
                                      status[Permission.camera] ==
                                          PermissionStatus.granted)
                                    _pickOrCaptureImage(ImageSource.camera);
                                },
                                icon: Icon(Icons.camera_alt_outlined,
                                    color: Colors.white),
                                color: kPrimaryColor,
                                textColor: Colors.white,
                                text: 'Camera',
                                textStyle: GoogleFonts.poppins(),
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
              RoundedInputField(
                  defaultValue: _nameParts != null && _firstName == null
                      ? _nameParts![0]
                      : _firstName,
                  enabled: !_isSigningUp,
                  icon: Icons.person_outline_outlined,
                  hintText: 'First name',
                  onChanged: (value) {
                    _firstName = value;
                  }),
              RoundedInputField(
                  defaultValue: (_nameParts != null &&
                          _nameParts!.length > 1 &&
                          _lastName == null)
                      ? _nameParts![_nameParts!.length - 1]
                      : _lastName,
                  icon: Icons.person_outline_outlined,
                  enabled: !_isSigningUp,
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
                  enabled: !_isSigningUp,
                  hintText: 'Email address',
                  onChanged: (value) {
                    _email = value;
                  }),
              RoundedPasswordField(
                  defaultValue: data != null && _password == null
                      ? data!['password']
                      : _password,
                  icon: Icons.vpn_key_outlined,
                  enabled: !_isSigningUp,
                  onChanged: (value) {
                    _password = value;
                  }),
              _accountIndex == 0
                  ? RoundedInputField(
                      defaultValue: _childName,
                      icon: Icons.child_friendly_outlined,
                      enabled: !_isSigningUp,
                      hintText: 'Child\'s name',
                      onChanged: (value) {
                        _childName = value;
                      })
                  : Container(),
              _accountIndex == 0
                  ? RoundedInputField(
                      defaultValue: _childAge,
                      icon: Icons.child_friendly_outlined,
                      enabled: !_isSigningUp,
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
                      enabled: !_isSigningUp,
                      onChanged: (value) {
                        _schoolName = value;
                      })
                  : Container(),
              _accountIndex == 1
                  ? RoundedInputField(
                      defaultValue: _schoolAddress,
                      icon: Icons.my_location_outlined,
                      hintText: 'Address of school',
                      enabled: !_isSigningUp,
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
                        labelStyle: GoogleFonts.poppins(
                            color: kPrimaryColor, fontSize: 18),
                        titleStyle: GoogleFonts.poppins(
                            color: kPrimaryColor, fontSize: 18),
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
                      GoogleFonts.poppins(color: kPrimaryColor, fontSize: 18),
                  titleStyle:
                      GoogleFonts.poppins(color: kPrimaryColor, fontSize: 18),
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
                      GoogleFonts.poppins(color: kPrimaryColor, fontSize: 18),
                  titleStyle:
                      GoogleFonts.poppins(color: kPrimaryColor, fontSize: 18),
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
              _actions(),
              /* RoundedButton(
                text: 'CONTINUE',
                press: () {
                  _signUp();
                },
              ), */
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
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData)
                return Container();
              else if (snapshot.connectionState == ConnectionState.done &&
                  !snapshot.hasData) return _actions();

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
            },
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
    /* Utils.showProgressDialog(
      context: context, 
      message: "Signing up...",
    ); */

    if (_firstName!.isEmpty ||
        _lastName!.isEmpty ||
        _email!.isEmpty ||
        _password!.isEmpty) {
      setState(() {
        _isSigningUp = false;
      });

      // Navigator.of(context, rootNavigator: true).pop();

      Utils.showSnackbar(
        context: context,
        message: MESSAGES['users']!['empty_field']!,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } else if (_email != null && !EmailValidator.validate(_email as String)) {
      setState(() {
        _isSigningUp = false;
      });

      // Navigator.of(context, rootNavigator: true).pop();

      Utils.showSnackbar(
        context: context,
        message: MESSAGES['email']!['invalid']!,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } else {
      Result<List<User>> users =
          await UserService.instance.getUser('email', _email);
      print('Check for existing email, done!');
      print('Users: ${users.data}');

      if (users.hasError) {
        print('Email address is available for registration');

        String _id = Uuid().v4();
        _password = DBCrypt().hashpw(_password as String, DBCrypt().gensalt());

        if (_profileImg != null) {
          Result<String> photoUrl =
              await UserService.instance.uploadPhoto(_id, _profileImg as File);
          _profileSrc = photoUrl.data;
        }

        User user = User(
            id: _id,
            firstName: _firstName!,
            lastName: (_lastName != null && _nameParts == null)
                ? _lastName!
                : _nameParts![_nameParts!.length - 1],
            email: (_email != null && (data != null || credential != null))
                ? _email!
                : (data != null)
                    ? data!['email']
                    : credential!.user!.email,
            gender: _genders[_genderIndex],
            password: _password!,
            schoolName:
                _schoolName != null && _accountIndex == 1 ? _schoolName! : '',
            schoolAddress: _schoolAddress != null && _accountIndex == 1
                ? _schoolAddress!
                : '',
            schoolType: _accountIndex == 1 ? _types[_typeOfSchool] : '',
            childName:
                _childName != null && _accountIndex == 0 ? _childName! : '',
            childAge: _childAge != null && _accountIndex == 0 ? _childAge! : '',
            photo: _profileSrc ?? "",
            type: _accountIndex,
            isDeleted: false);

        Result<dynamic> result = await UserService.instance.setUser(user);

        if (result.hasError) {
          setState(() {
            _isSigningUp = false;
          });

          Utils.showSnackbar(
            context: context,
            message: result.message,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );

          return null;
        }

        Map<String, dynamic> oldData =
            await Cache.load('user', <String, dynamic>{});
        Map<String, dynamic> newData = user.toJson();
        newData['isGoogle'] = oldData['isGoogle'];
        await Cache.write('user', newData);

        setState(() {
          _isSigningUp = false;
        });

        /* Navigator.of(context, rootNavigator: true).pop();

        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => _accountIndex == Role.TEACHER.accessLevel 
              ? TeacherPanel() 
              : ParentPanel(),
          ),
        ); */

        UserService.instance.setUser(user).then((_) async {
          print('User saved');

          Map<String, dynamic> oldData =
              await Cache.load('user', <String, dynamic>{});
          Map<String, dynamic> newData = user.toJson();
          newData['isGoogle'] = oldData['isGoogle'];
          await Cache.write('user', newData);

          setState(() {
            _isSigningUp = false;
          });

          // Navigator.of(context, rootNavigator: true).pop();

          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _accountIndex == Role.TEACHER.accessLevel
                  ? TeacherPanel()
                  : ParentPanel(),
            ),
          );
        }).catchError((_) {
          Utils.showAlertDialog(
            context: context,
            title: "Sign Up Failed",
            message: "Cause: ${_.toString()}",
            actions: [],
          );
        });

        return Result();
      } else {
        setState(() {
          _isSigningUp = false;
        });

        // Navigator.of(context, rootNavigator: true).pop();

        Utils.showSnackbar(
          context: context,
          message: "Email address already exists!",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }

      return null;
    }
  }
}

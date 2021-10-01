import 'package:dbcrypt/dbcrypt.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter_cache/flutter_cache.dart' as Cache;
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../components/already_have_an_account_check.dart';
import '../../../../components/rounded_button.dart';
import '../../../../components/rounded_input_field.dart';
import '../../../../components/rounded_password_field.dart';
import '../../../auth/auth.dart';
import '../../../constants.dart';
import '../../../enums/role_enum.dart';
import '../../../models/result_model.dart';
import '../../../models/user_model.dart';
import '../../../services/user_services.dart';
import '../../../utils/utils.dart';
import '../../admin/admin_panel.dart';
import '../../parent/parent_panel.dart';
import '../../signup/signup_screen.dart';
import '../../teacher/teacher_panel.dart';
import 'background.dart';
import 'or_divider.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  String? _email, _password;
  String message = '';
  bool _loggingIn = false;
  bool _hasError = false;
  int _method = 0;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Sign In",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: size.height * 0.03),
            SvgPicture.asset(
              "images/icons/login.svg",
              height: size.height * 0.35,
            ),
            SizedBox(height: size.height * 0.03),
            RoundedInputField(
              hintText: "Email address",
              onChanged: (value) {
                _email = value;
              },
            ),
            RoundedPasswordField(
              onChanged: (value) {
                _password = value;
              },
            ),
            _hasError ? _showError(message) : Container(),
            !_loggingIn
                ? _actions(size, context)
                : FutureBuilder(
                    future: _method == 0 
                      ? _login()
                      : _loginWithGoogle(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                        final User user = snapshot.data as User;

                        WidgetsBinding.instance!.addPostFrameCallback((_) async {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();

                          Map<String, dynamic> data = await Cache.load('user', <String, dynamic>{});
                          Map<String, dynamic> userData = user.toJson();
                          userData.addAll(data);

                          await Cache.write('user', userData);
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) {
                                if(user.type == Role.PARENT.accessLevel)
                                  return ParentPanel();
                                else if(user.type == Role.TEACHER.accessLevel)
                                  return TeacherPanel();
                                
                                return AdminPanel();
                              }
                            ),
                          );

                          _loggingIn = false;
                        });

                        return _actions(size, context);
                      } else if (snapshot.connectionState == ConnectionState.done && !snapshot.hasData)
                        return _actions(size, context);
                      else {
                        return Column(
                          children: [
                            SizedBox(
                              height: 50,
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
                      }
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _actions(Size size, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RoundedButton(
          text: "SIGN IN",
          press: () {
            setState(() {
              _loggingIn = true;
            });
          },
        ),
        SizedBox(height: size.height * 0.03),
        AlreadyHaveAnAccountCheck(
          press: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return SignUpScreen();
                },
              ),
            );
          },
        ),
        OrDivider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.red.shade700,
                elevation: 0,
                focusElevation: 0,
                hoverElevation: 0,
                highlightElevation: 0,
                disabledElevation: 0,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "images/icons/google-plus.svg",
                      width: 30,
                      height: 30,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Continue with Google',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  setState(() {
                    _loggingIn = true;
                    _method = 1;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _showError(String message) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 10,),
          Text(message, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.red),),
          SizedBox(height: 10,)
        ],
      ),
    );
  }

  Future<User?> _login() async {
    if(_email == null || (_email != null && !EmailValidator.validate(_email as String)))
      setState(() {
        _loggingIn = false;
        _hasError = true;
        message = MESSAGES['email']!['invalid'] as String;
      });
    else if(_password == null || (_password != null && _password!.isEmpty))
      setState(() {
        _loggingIn = false;
        _hasError = true;
        message = MESSAGES['password']!['short'] as String;
      });
    else
    {
      Result<List<User>> data = await UserService.instance.getUser(
        'email',
        _email
      );

      if(data.data != null && data.data!.length > 0)
      {
        User user = data.data![0];

        if(DBCrypt().checkpw(_password as String, user.password))
        {
          if(user.isDeleted) {
            Map<String, dynamic> json = user.toJson();
            json['is_deleted'] = false;
            user = User.fromJson(json);

            Utils.showProgressDialog(
              context: context, 
              message: 'Recovering your account...',
            );

            await UserService.instance.recoverUser(user);

            Navigator.of(context, rootNavigator: true).pop();
          }

          return user;
        }
        else 
          setState(() {
            _loggingIn = false;
            _hasError = true;
            message = MESSAGES['password']!['incorrect'] as String;
          });
      }
      else 
        setState(() {
          _loggingIn = false;
          _hasError = true;
          message = MESSAGES['email']!['not_exist'] as String;
        });
    }

    return null;
  }

  Future<User?> _loginWithGoogle() async {
    Result<dynamic> result = await Auth.instance.signUpWithGoogle();
    Map<String, dynamic> data = await Cache.load('user', <String, dynamic>{});
    await Cache.write('user', data);

    if(result.hasError) 
      setState(() {
        _loggingIn = false;
        _hasError = true;
        message = '${result.message}';
      });
    else
    {
      UserCredential credential = result.data as UserCredential;
      Result<List<User>> _result = await UserService.instance.getUser("email", credential.user!.email);

      if(_result.hasError)
        setState(() {
          _loggingIn = false;
          _hasError = true;
          message = 'You haven\'t signed up for an account yet';
        });
      else
        return (_result.data as List<User>)[0];
    }
    
    return null;
  }
}

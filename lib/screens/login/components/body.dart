import 'package:dbcrypt/dbcrypt.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache/flutter_cache.dart' as Cache;
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../components/already_have_an_account_check.dart';
import '../../../../components/rounded_button.dart';
import '../../../../components/rounded_input_field.dart';
import '../../../../components/rounded_password_field.dart';
import '../../../constants.dart';
import '../../../models/result_model.dart';
import '../../../models/user_model.dart';
import '../../../services/user_services.dart';
import '../../signup/signup_screen.dart';
import '../../teacher/teacher_panel.dart';
import 'background.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  String? _email, _password;
  String message = '';
  bool _loggingIn = false;
  bool _hasError = false;

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
                    future: _login(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                        final User user = snapshot.data as User;

                        WidgetsBinding.instance!.addPostFrameCallback((_) async {
                          Navigator.of(context).pop();

                          await Cache.write('user', user.toJson());
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => user.type == 1
                                ? TeacherPanel()
                                : Container(),
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

            await UserService.instance.recoverUser(user);
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
}

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache/flutter_cache.dart' as Cache;
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../components/already_have_an_account_check.dart';
import '../../../../../components/rounded_button.dart';
import '../../../../../components/rounded_input_field.dart';
import '../../../../../components/rounded_password_field.dart';
import '../../../auth/auth.dart';
import '../../../constants.dart';
import '../../../models/result_model.dart';
import '../../additional_signup/additional_signup_screen.dart';
import '../../login/login_screen.dart';
import 'background.dart';
import 'or_divider.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  ScrollController _scrollController = ScrollController();
  String? _email, _password;
  String _message = '';

  int _method = 0;
  bool _signingUp = false;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20,),
            Text(
              "Create an Account",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24), 
            ),
            SizedBox(height: size.height * 0.03),
            SvgPicture.asset(
              "images/icons/signup.svg",
              height: size.height * 0.35,
            ),
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
            _hasError 
                ? _showError(_message) 
                : Container(),
            !_signingUp
                ? _actions(size)
                : FutureBuilder(
                    future: _method == 2
                        ? _signUpUsingEmailAndPassword() 
                        : _signUpUsingSocialMedia(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                        final Object data = snapshot.data!;
                        
                        WidgetsBinding.instance!.addPostFrameCallback((_) async {

                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AdditionalSignUpScreen(
                                data is UserCredential && _method != 2 ? data : null, 
                                data is Map<String, dynamic> && _method == 2 ? data : null, 
                                _method != 2
                              )
                            )
                          );

                          _signingUp = false;
                          _method = 0; 
                        });

                        return _actions(size);
                      } else if (snapshot.connectionState == ConnectionState.done && !snapshot.hasData) {
                        return _actions(size);
                      } else {
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
                      }
                    },
                  ),
            SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }

  Widget _actions(Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RoundedButton(
          text: "SIGN UP",
          press: () {
            if(_email == null || _password == null || _email!.isEmpty || _password!.isEmpty)
              setState(() {
                _signingUp = false;
                _hasError = true;
                _message = MESSAGES['users']!['empty_field']!;
              });
            else if(_email != null && !EmailValidator.validate(_email!))
              setState(() {
                _signingUp = false;
                _hasError = true;
                _message = MESSAGES['email']!['invalid']!;
              });
            else
              setState(() {
                _signingUp = true;
                _method = 2;
              });
          },
        ),
        SizedBox(height: size.height * 0.03),
        AlreadyHaveAnAccountCheck(
          login: false,
          press: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return LoginScreen();
                },
              ),
            );
          },
        ),
        OrDivider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // REMOVED FACEBOOK SUPPORT (FOR NOW)
            /* SocialIcon(
              iconSrc: "images/icons/facebook.svg",
              press: () async {
                Result<dynamic> result = await Auth.instance.signUpWithFacebookFromWebView(context);

                if(!result.hasError) {
                  Map<String, dynamic> data = await Cache.load('user', <String, dynamic>{});
                  data['isGoogle'] = false;
                  await Cache.write('user', data);

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AdditionalSignUpScreen(result.data, null, true), 
                    ),
                  );
                }
                else 
                  setState(() {
                    _hasError = true;
                    _message = result.message;
                  });
              },
            ), */
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
                    _signingUp = true;
                    _method = 1;
                  });
                },
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _showError(String message) {
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
            message, 
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

  Future<UserCredential?> _signUpUsingSocialMedia() async {
    Result<dynamic> result = await Auth.instance.signUpWithGoogle();
    Map<String, dynamic> data = await Cache.load('user', <String, dynamic>{});
    data['isGoogle'] = true;
    await Cache.write('user', data);

    if(result.hasError) 
      setState(() {
        _signingUp = false;
        _hasError = true;
        _message = '${result.message}';
      });
    else
      return result.data as UserCredential;
    
    return null;
  }

  Future<Map<String, dynamic>?> _signUpUsingEmailAndPassword() async {
    if(_email == null || _password == null || _email!.isEmpty || _password!.isEmpty)
      setState(() {
        _signingUp = false;
        _hasError = true;
        _message = MESSAGES['users']!['empty_field']!;
      });
    else if(_email != null && !EmailValidator.validate(_email!))
      setState(() {
        _signingUp = false;
        _hasError = true;
        _message = MESSAGES['email']!['invalid']!;
      });
    else
    {
      Result<Map<String, dynamic>> data = await Auth.instance.signUpWithEmailAndPassword(
        _email!, 
        _password!
      );

      if(data.hasError)
        setState(() {
          _signingUp = false;
          _hasError = true;
          _message = data.message;
        });
      else
        return data.data as Map<String, dynamic>;
    }

    return null;
  }
}

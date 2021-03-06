import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/services.dart';
import 'package:flutter_cache/flutter_cache.dart' as Cache;
import 'package:google_sign_in/google_sign_in.dart';

import '../constants.dart';
import '../models/result_model.dart';
import '../models/user_model.dart';
import '../services/user_services.dart';

class Auth {
  static FirebaseAuth _auth = FirebaseAuth.instance;

  static Auth get instance {
    if (!kIsProduction)
      _auth.useAuthEmulator(
        FIREBASE_EMULATOR_HOST,
        FIREBASE_AUTH_EMULATOR_PORT,
      );

    return Auth();
  }

  Future<Result<dynamic>> signUpWithGoogle() async {
    Result<dynamic> result = Result();

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount user =
          await googleSignIn.signIn() as GoogleSignInAccount;
      final GoogleSignInAuthentication auth = await user.authentication;
      final credentials = GoogleAuthProvider.credential(
          accessToken: auth.accessToken, idToken: auth.idToken);

      Map<String, dynamic> data = await Cache.load('user', <String, dynamic>{});
      data['token'] = auth.accessToken;
      data['isGoogle'] = true;
      await Cache.write('user', data);

      UserCredential credential = await _auth.signInWithCredential(credentials);
      result = Result(data: credential);

      googleSignIn.signOut();
    } on PlatformException catch (e) {
      result = Result(message: e.message as String, hasError: true);
    } on FirebaseAuthException catch (e) {
      result = Result(message: e.message as String, hasError: true);
    }

    return result;
  }

  /* REMOVED BECAUSE OF LOGGING IN ISSUES
  Future<Result<dynamic>> signUpWithFacebook() async {
    Result<dynamic> _result = Result();

    try {
      final LoginResult result = await FacebookAuth.instance.login();
      final AccessToken accessToken = result.accessToken as AccessToken;
      final credentials = FacebookAuthProvider.credential(accessToken.token);

      Map<String, dynamic> data = await Cache.load('user', <String, dynamic>{});
      data['token'] = accessToken.token;
      await Cache.write('user', data);

      UserCredential credential = await _auth.signInWithCredential(credentials);
      _result = Result(data: credential);
    } on PlatformException catch(e) {
      _result = Result(message: e.message as String, hasError: true);
    } on FirebaseAuthException catch (e) {
      _result = Result(message: e.message as String, hasError: true);
    }

    return _result;
  }
  */

  /* REMOVED BECAUSE OF FACEBOOK'S STRICT REQUIREMENTS
  Future<Result<dynamic>> signUpWithFacebookFromWebView(BuildContext context) async {
    Result<dynamic> _result = Result();

    String? token = await Navigator.of(context).push(
      MaterialPageRoute(
        maintainState: true,
        builder: (_) => CustomWebView(
          "https://www.facebook.com/dialog/oauth?client_id=$FB_CLIENT_ID&redirect_uri=$FB_REDIRECT_URL&response_type=token&scope=email,public_profile,"
        ),
      ),
    );

    if(token != null) {
      try {
        Map<String, dynamic> data = await Cache.load('user', <String, dynamic>{});
        data['token'] = token;
        await Cache.write('user', data);

        final credentials = FacebookAuthProvider.credential(token);
        UserCredential user = await _auth.signInWithCredential(credentials);
        _result = Result(data: user);
      } catch(e) {
        _result = Result(message: "Signup Failed: $e", hasError: true);
      }
    } else 
      _result = Result(message: "Signup Failed: No access token received", hasError: true);

    return _result;
  }
  */

  Future<Result<Map<String, dynamic>>> signUpWithEmailAndPassword(
      String email, String password) async {
    Result<List<User>> result =
        await UserService.instance.getUser('email', email);

    return Result<Map<String, dynamic>>(
        data: {'email': email, 'password': password},
        message: MESSAGES['email']?['exist'] as String,
        hasError: result.data != null);
  }

  Future<void> signOutUsingFirebaseAuth() async {
    return await _auth.signOut();
  }

  Future<void> deleteCurrentUser() async {
    return await _auth.currentUser!.delete();
  }

  Future<UserCredential?> reauthenticateUser(bool isGoogle) async {
    dynamic user = _auth.currentUser!;

    if (user != null) {
      Map<String, dynamic> data = await Cache.load('user', <String, dynamic>{});
      print(data);

      final credential = isGoogle
          ? GoogleAuthProvider.credential(accessToken: data['token'])
          : FacebookAuthProvider.credential(data['token']);

      UserCredential user = await _auth.signInWithCredential(credential);
      return user;
    }
  }
}

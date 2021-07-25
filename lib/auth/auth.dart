import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class Auth {
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount user = await GoogleSignIn().signIn() as GoogleSignInAccount;
    final GoogleSignInAuthentication auth = await user.authentication;
    final credentials = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken
    );

    return await FirebaseAuth.instance.signInWithCredential(credentials);
  }

  Future<UserCredential> signInWithFacebook() async {
    final AccessToken token = await FacebookAuth.instance.login() as AccessToken;
    final credentials = FacebookAuthProvider.credential(token.token);
    
    return await FirebaseAuth.instance.signInWithCredential(credentials);
  }
}
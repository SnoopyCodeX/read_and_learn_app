import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'components/body.dart';

class AdditionalSignUpScreen extends StatefulWidget {
  final UserCredential? credential;
  final Map<String, dynamic>? data;
  final bool usingSocMed;

  AdditionalSignUpScreen(
    this.credential,
    this.data,
    this.usingSocMed
  );

  @override
  _AdditionalSignUpScreenState createState() => _AdditionalSignUpScreenState(credential, data, usingSocMed);
}

class _AdditionalSignUpScreenState extends State<AdditionalSignUpScreen> {
  final UserCredential? credential;
  final Map<String, dynamic>? data;
  final bool usingSocMed;

  _AdditionalSignUpScreenState(
    this.credential,
    this.data,
    this.usingSocMed
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ConnectivityWidgetWrapper(
          alignment: Alignment.topCenter,
          disableInteraction: true,
          child: Body(credential, data, usingSocMed)
        ),
      ),
    );
  }
}
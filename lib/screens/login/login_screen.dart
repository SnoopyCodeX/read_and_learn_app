  
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import './components/body.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ConnectivityWidgetWrapper(
          alignment: Alignment.topCenter,
          disableInteraction: true,
          child: Body()
        ),
      ),
    );
  }
}
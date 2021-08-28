import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';

import 'components/body.dart';

class TeacherPanel extends StatefulWidget {
  @override
  _TeacherPanelState createState() => _TeacherPanelState();
}

class _TeacherPanelState extends State<TeacherPanel> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: ConnectivityWidgetWrapper(
          alignment: Alignment.topCenter,
          disableInteraction: true,
          child: SingleChildScrollView(
            child: Body(),
          ),
        ),
      ),
    );
  }
}

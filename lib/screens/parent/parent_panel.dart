//import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';

import 'components/body.dart';

class ParentPanel extends StatefulWidget {
  const ParentPanel({Key? key}) : super(key: key);

  @override
  _ParentPanelState createState() => _ParentPanelState();
}

class _ParentPanelState extends State<ParentPanel> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SingleChildScrollView(
          child: Body(),
        ),
      ),
    );
  }
}

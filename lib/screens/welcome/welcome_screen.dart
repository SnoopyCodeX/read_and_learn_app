import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache/flutter_cache.dart' as Cache;

import '../../enums/role_enum.dart';
import '../admin/admin_panel.dart';
import '../parent/parent_panel.dart';
import '../teacher/teacher_panel.dart';
import 'components/body.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();

    _isLoggedIn();
  }

  Future<void> _isLoggedIn() async {
    Map<String, dynamic> data = await Cache.load('user', <String, dynamic>{});

    if(data.isNotEmpty) {
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) {
            if(data['type'] == Role.PARENT.accessLevel)
              return ParentPanel();
            else if(data['type'] == Role.TEACHER.accessLevel)
              return TeacherPanel();

            return AdminPanel();
          }
        ),
      );
    }
  }

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
import 'package:flutter/material.dart';
import 'package:flutter_cache/flutter_cache.dart' as Cache;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../constants.dart';
import '../../../../models/classroom_model.dart';
import '../../../../models/result_model.dart';
import '../../../../models/user_model.dart';
import '../../../../providers/temp_variables_provider.dart';
import '../../../../services/classroom_services.dart';
import '../../../../services/user_progress_services.dart';
import '../../../../utils/utils.dart';
import '../certificate/certificate_screen.dart';
import 'navbar.dart';
import 'sub_components/active_members_page.dart';
import 'sub_components/home_page.dart';

class Body extends StatefulWidget {
  final void Function() reloadAndOpenRoom;
  final void Function({bool refresh}) resetSelectedRoom;
  final Classroom classroom;

  const Body(this.classroom, this.reloadAndOpenRoom, this.resetSelectedRoom);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int _index = 1;

  User? _user;

   @override
  void initState() {
    super.initState();

    Provider.of<TempVariables>(context, listen: false).pageChanged = () {
      setState(() {
        _index = Provider.of<TempVariables>(context, listen: false).tempIndex;
      });
    };

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    Map<String, dynamic> json = await Cache.load('user', <String, dynamic>{});
    _user = User.fromJson(json);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomNavBar(
          resetSelectedRoom: widget.resetSelectedRoom,
          classroom: widget.classroom, 
          onOptionSelected: (option) async {
            switch(option.toLowerCase()) {
              case 'leave class':
                _showLeaveDialog(widget.classroom.id);
              break;

              case 'reset all progress':
                _showResetDialog();
              break;
            }
          },
        ),

        if(_index == 0)
          ClassroomActiveMembersPanel(widget.classroom)
        else if(_index == 1)
          ClassroomHomePanel(widget.classroom)
        else if(_index == 2)
          CertificateScreen(widget.classroom),
      ],
    );
  }

  void _showLeaveDialog(String classId) {
    Utils.showAlertDialog(
      context: context, 
      title: 'Confirm Leave', 
      message: 'Do you really want to leave this class?', 
      actions: [
        TextButton(
          onPressed: () => _leaveClassroom(classId),
          child: Text(
            'Yes',
            style: GoogleFonts.poppins(
              color: kPrimaryColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          child: Text(
            'No',
            style: GoogleFonts.poppins(
              color: kPrimaryColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _leaveClassroom(String classId) async {
    // Dismiss previous dialog
    Navigator.of(context, rootNavigator: true).pop();

    Utils.showProgressDialog(
      context: context, 
      message: 'Leaving classroom...',
    );

    Map<String, dynamic> userData = await Cache.load('user', <String, dynamic>{});
    await ClassroomService.instance.leaveClassroom(userData['id'], classId);

    // Dismiss progress dialog
    Navigator.of(context, rootNavigator: true).pop();

    // Close this panel
    Navigator.of(context).pop();
  }

  void _showResetDialog() {
    Utils.showAlertDialog(
      context: context,
      title: "Confirm Action",
      message: "Do you really want to reset your progress?",
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop();

            Utils.showProgressDialog(
              context: context,
              message: "Resetting progress...",
            );

            Result<dynamic> result = await UserProgressService.instance.resetAllUserProgress(_user!.id, widget.classroom.id);
            Navigator.of(context, rootNavigator: true).pop();

            Utils.showSnackbar(
              context: context,
              message: result.message,
              backgroundColor: result.hasError ? Colors.red : Colors.green,
              textColor: Colors.white,
            );

            if(!result.hasError)
              setState(() {});
          },
          child: Text(
            'Yes',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          child: Text(
            'No',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}
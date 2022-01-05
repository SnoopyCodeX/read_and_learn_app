import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../models/classroom_model.dart';
import '../../../models/result_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/temp_variables_provider.dart';
import '../../../services/classroom_member_services.dart';
import '../../../services/classroom_services.dart';
import '../../../utils/utils.dart';
import '../classroom/classroom_panel.dart';

class ClassroomListItem extends StatefulWidget {
  final void Function() refreshListener;
  final Classroom classroom;
  final User user;
  const ClassroomListItem(
      {Key? key,
      required this.classroom,
      required this.user,
      required this.refreshListener})
      : super(key: key);

  @override
  _ClassroomListItemState createState() => _ClassroomListItemState();
}

class _ClassroomListItemState extends State<ClassroomListItem> {
  Classroom? _selectedRoom;
  int _numOfStudents = -1;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (_selectedRoom != null)
        Navigator.of(context).push(
          MaterialPageRoute(
            settings: RouteSettings(name: ClassroomPanel.NAME),
            builder: (context) => ClassroomPanel(
              widget.classroom,
              () => _reloadAndOpenRoom(widget.classroom),
              ({bool refresh = false}) => _resetSelectedRoom(refresh: refresh),
            ),
          ),
        );
    });

    if (_numOfStudents == -1) _getNumOfStudents(widget.classroom.id);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      width: 300,
      height: 160,
      child: InkWell(
        onTap: () {
          _selectedRoom = widget.classroom;

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ClassroomPanel(
                widget.classroom,
                () => _reloadAndOpenRoom(widget.classroom),
                ({bool refresh = false}) =>
                    _resetSelectedRoom(refresh: refresh),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Card(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.classroom.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            height: 1,
                          ),
                        ),
                        Text(
                          widget.classroom.section,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.exit_to_app_outlined),
                      onPressed: () => _showLeaveDialog(widget.classroom.id),
                    ),
                  ],
                ),
                Spacer(),
                Text(
                  '$_numOfStudents Student(s)',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _resetSelectedRoom({bool refresh = false}) {
    _selectedRoom = null;

    if (refresh)
      widget.refreshListener();
    else
      Provider.of<TempVariables>(context, listen: false).setTempIndex(1);
  }

  Future<void> _reloadAndOpenRoom(Classroom classroom) async {
    Result<List<Classroom>> result =
        await ClassroomService.instance.getClassroom('id', classroom.id);
    _selectedRoom = result.data![0];

    // Refresh UI
    setState(() {});
  }

  Future<void> _getNumOfStudents(String id) async {
    _numOfStudents =
        (await ClassMemberService.instance.countStudentsFromClass(id));

    setState(() {});
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

    await ClassroomService.instance.leaveClassroom(widget.user.id, classId);

    // Dismiss progress dialog
    Navigator.of(context, rootNavigator: true).pop();

    // Refresh list
    widget.refreshListener();
  }
}

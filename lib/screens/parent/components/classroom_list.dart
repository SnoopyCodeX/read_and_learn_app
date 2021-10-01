import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants.dart';
import '../../../models/classroom_model.dart';
import '../../../models/result_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/temp_variables_provider.dart';
import '../../../services/classroom_member_services.dart';
import '../../../services/classroom_services.dart';
import '../../../utils/utils.dart';
import '../classroom/classroom_panel.dart';

class ClassroomList extends StatefulWidget {
  final void Function() refreshListener;
  final User user;

  const ClassroomList(this.user, this.refreshListener);

  @override
  _ClassroomListState createState() => _ClassroomListState();
}

class _ClassroomListState extends State<ClassroomList> {
  Classroom? _selectedRoom;
  int _numOfStudents = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ClassroomService.instance.getJoinedClassroom(widget.user.id),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.done && snapshot.hasData)
        {
          Result<List<Classroom>> data = snapshot.data as Result<List<Classroom>>;

          if(!data.hasError)
          {
            List<Classroom> classrooms = data.data as List<Classroom>;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: classrooms.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    Classroom classroom = classrooms[index];
                    _getNumOfStudents(classroom.id);

                    WidgetsBinding.instance!.addPostFrameCallback((_) {
                      if(_selectedRoom != null)
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            settings: RouteSettings(name: ClassroomPanel.NAME),
                            builder: (context) => ClassroomPanel(
                              classroom, 
                              () => _reloadAndOpenRoom(classroom), 
                              ({bool refresh = false}) => _resetSelectedRoom(refresh: refresh),
                            ),
                          ),
                        );
                    });

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      width: 300,
                      height: 160,
                      child: InkWell(
                        onTap: () {
                          _selectedRoom = classroom;

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ClassroomPanel(
                                classroom, 
                                () => _reloadAndOpenRoom(classroom), 
                                ({bool refresh = false}) => _resetSelectedRoom(refresh: refresh),
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
                                          classroom.name,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            height: 1,
                                          ),
                                        ),
                                        Text(
                                          classroom.section,
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    IconButton(
                                      icon: Icon(Icons.exit_to_app_outlined),
                                      onPressed: () => _showLeaveDialog(classroom.id),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Text(
                                  '$_numOfStudents Student(s)',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                  )
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          }

          return Center(
            child: Container(
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 300,
                    child: SvgPicture.asset("images/illustrations/empty.svg"),
                  ),
                  Text(
                    'No classes found',
                    style: GoogleFonts.poppins(
                      color: kPrimaryColor,
                      letterSpacing: 2,
                      wordSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        else if(snapshot.connectionState == ConnectionState.done && !snapshot.hasData)
          return Expanded(
            child: Center(
              child: Container(
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: 300,
                      child: SvgPicture.asset("images/illustrations/empty.svg"),
                    ),
                    Text(
                      'No classes found',
                      style: GoogleFonts.poppins(
                        color: kPrimaryColor,
                        letterSpacing: 2,
                        wordSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                width: 300,
                height: 160,
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[200]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              height: 26,
                              color: Colors.grey.shade100,
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[200]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              height: 18,
                              color: Colors.grey.shade100,
                            ),
                          ),
                        ),
                        Spacer(),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[200]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              height: 18,
                              color: Colors.grey.shade100,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _resetSelectedRoom({bool refresh = false}) {
    _selectedRoom = null;

    if(refresh)
      widget.refreshListener();
    else 
      Provider.of<TempVariables>(context, listen: false).setTempIndex(1);
  }

  Future<void> _reloadAndOpenRoom(Classroom classroom) async {
    Result<List<Classroom>> result = await ClassroomService.instance.getClassroom('id', classroom.id);
    _selectedRoom = result.data![0];

    // Refresh UI
    setState(() {});
  }

  Future<void> _getNumOfStudents(String id) async {
    _numOfStudents = (await ClassMemberService.instance.countStudentsFromClass(id)) - 1;
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
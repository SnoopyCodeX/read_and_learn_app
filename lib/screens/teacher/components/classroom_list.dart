import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../components/rounded_input_field.dart';
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
  TextEditingController? _nameController, _sectionController;
  Classroom? _selectedRoom;
  String? _name, _section;
  int _numOfStudents = 0;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _sectionController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();

    _nameController!.dispose();
    _sectionController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ClassroomService.instance.getActiveClassroom('teacher', widget.user.id),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.done && snapshot.hasData)
        {
          Result<List<Classroom>> data = snapshot.data as Result<List<Classroom>>;

          if(!data.hasError)
          {
            List<Classroom> classrooms = data.data as List<Classroom>;

            return Column(
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
                                    PopupMenuButton<String>(
                                      icon: Icon(Icons.menu_open_outlined),
                                      itemBuilder: (builder) => CLASSROOM_OPTIONS.map((option) => PopupMenuItem<String>(
                                        value: option,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(option.toLowerCase() == 'edit' ? Icons.edit_outlined : Icons.delete_outlined),
                                            SizedBox(width: 10),
                                            Text(
                                              option,
                                              style: GoogleFonts.poppins(),
                                            ),
                                          ],
                                        ),
                                      )).toList(),
                                      onSelected: (option) {
                                        switch(option) {
                                          case 'Edit':
                                            _showEditDialog(classroom);
                                          break;

                                          case 'Delete':
                                            _showDeleteDialog(classroom);
                                          break;
                                        }
                                      },
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
    _numOfStudents = await ClassMemberService.instance.countStudentsFromClass(id);
  }

  Future<void> _deleteClass(String id) async {
    // Dismiss dialog
    Navigator.of(context, rootNavigator: true).pop();

    // Show progress dialog
    Utils.showProgressDialog(
      context: context, 
      message: 'Deleting class...',
    );

    // Delete classroom and wait for result
    Result<void> result = await ClassroomService.instance.deleteClassroom(id);

    // Dismiss progress dialog
    Navigator.of(context, rootNavigator: true).pop();

    // Show snackbar
    Utils.showSnackbar(
      context: context,
      message: result.message, 
      actionLabel: 'OK', 
      onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
    );

    // Refresh UI
    widget.refreshListener();
  }

  void _showDeleteDialog(Classroom classroom) {
    Utils.showAlertDialog(
      context: context, 
      title: 'Confirm Delete', 
      message: 'Do you really want to delete this class?', 
      actions: [
        TextButton(
          onPressed: () => _deleteClass(classroom.id),
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

  void _showEditDialog(Classroom classroom) {
    _name = classroom.name;
    _section = classroom.section;

    Utils.showCustomAlertDialog(
			context: context,
			content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Edit class',
              style: GoogleFonts.poppins(
                color: kPrimaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 22,
              ),
            ),
            SizedBox(height: 10),
            RoundedInputField(
              icon: Icons.card_membership_outlined,
              defaultValue: _name ?? classroom.name,
							controller: _nameController,
              hintText: 'Name', 
              onChanged: (string) {
                _name = string;
              }
            ),
            SizedBox(height: 10),
            RoundedInputField(
              icon: Icons.cast_for_education_outlined,
              defaultValue: _section ?? classroom.section,
							controller: _sectionController,
              hintText: 'Section', 
              onChanged: (string) {
                _section = string;
              }
            ),
          ],
        ),
      ),
			actions: [
				TextButton(
          onPressed: () => _saveEditedClass(classroom),
          child: Text(
            'Save',
            style: GoogleFonts.poppins(
            	color: kPrimaryColor,
            	fontWeight: FontWeight.w400,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
						// Reset variables
						_name = null;
						_section = null;

						// Reset controllers
						_nameController!.text = '';
						_sectionController!.text = '';

						// Close dialog
						Navigator.of(context, rootNavigator: true).pop();
					},
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(
              color: Colors.red,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
			],
		);
  }

  Future<void> _saveEditedClass(Classroom classroom) async {
    // Dismiss dialog
    Navigator.of(context, rootNavigator: true).pop();

    // Check if fields are empty
    if(_name == null || _section == null || _name!.isEmpty || _section!.isEmpty)
    {
      Utils.showSnackbar(
        context: context,
        message: 'Please fill in the required fields.', 
        actionLabel: 'OK', 
        onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
      );

      return;
    }

    // Change model to json then update values
    Map<String, dynamic> json = classroom.toJson();
    json['name'] = _name!;
    json['section'] = _section!;

    // Show progress dialog
    Utils.showProgressDialog(
      context: context, 
      message: 'Saving changes...',
    );

    // Save changes and wait for result
    Result<void> result = await ClassroomService.instance.setClassroom(Classroom.fromJson(json));

    // Dismiss progress dialog
    Navigator.of(context, rootNavigator: true).pop();

    // Show snackbar
    Utils.showSnackbar(
      context: context,
      message: result.message, 
      actionLabel: 'OK', 
      onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
    );

    // Reset variables
    _name = null;
    _section = null;

    // Reset controllers
    _nameController!.text = '';
    _sectionController!.text = '';

    // Refresh UI
    widget.refreshListener();
  }
}
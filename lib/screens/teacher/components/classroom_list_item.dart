import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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

class ClassroomListItem extends StatefulWidget {
  final void Function() refreshListener;
  final Classroom classroom;
  final User user;
  const ClassroomListItem({ Key? key, required this.classroom, required this.user, required this.refreshListener }) : super(key: key);

  @override
  _ClassroomListItemState createState() => _ClassroomListItemState();
}

class _ClassroomListItemState extends State<ClassroomListItem> {
  TextEditingController? _nameController, _sectionController;
  Classroom? _selectedRoom;
  String? _name, _section;
  int _numOfStudents = -1;

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

    if(_numOfStudents <= -1)
      _getNumOfStudents(widget.classroom.id);

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
                    PopupMenuButton<String>(
                      icon: Icon(Icons.menu_open_outlined),
                      itemBuilder: (builder) => CLASSROOM_OPTIONS
                        .map((option) => PopupMenuItem<String>(
                          value: option,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(option.toLowerCase() == 'edit'
                                    ? Icons.edit_outlined
                                    : Icons.delete_outlined),
                                SizedBox(width: 10),
                                Text(
                                  option,
                                  style: GoogleFonts.poppins(),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                      onSelected: (option) {
                        switch (option) {
                          case 'Edit':
                            _showEditDialog(widget.classroom);
                          break;

                          case 'Delete':
                            _showDeleteDialog(widget.classroom);
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
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../components/rounded_input_field.dart';
import '../../../../constants.dart';
import '../../../../models/classroom_model.dart';
import '../../../../models/result_model.dart';
import '../../../../providers/temp_variables_provider.dart';
import '../../../../services/classroom_services.dart';
import '../../../../utils/utils.dart';
import 'navbar.dart';
import 'sub_components/active_members_page.dart';
import 'sub_components/home_page.dart';
import 'sub_components/pending_members_page.dart';

class Body extends StatefulWidget {
  final void Function() reloadAndOpenRoom;
  final void Function({bool refresh}) resetSelectedRoom;
  final Classroom classroom;

  const Body(this.classroom, this.reloadAndOpenRoom, this.resetSelectedRoom);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  TextEditingController? _nameController, _sectionController;
  String? _name, _section;
  int _index = 1;

   @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _sectionController = TextEditingController();

    Provider.of<TempVariables>(context, listen: false).pageChanged = () {
      setState(() {
        _index = Provider.of<TempVariables>(context, listen: false).tempIndex;
      });
    };
  }

  @override
  void dispose() {
    super.dispose();

    _nameController!.dispose();
    _sectionController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomNavBar(
          resetSelectedRoom: widget.resetSelectedRoom,
          classroom: widget.classroom, 
          onOptionSelected: (option) async {
            switch(option) {
              case 'Copy class code':
                await FlutterClipboard.copy(widget.classroom.code);
                Utils.showSnackbar(
                  context: context, 
                  message: 'Copied to clipboard!',
                );
              break;

              case 'Edit':
                _showEditDialog(widget.classroom);
              break;

              case 'Delete':
                _showDeleteDialog(widget.classroom);
              break;
            }
          },
        ),

        if(_index == 0)
          ClassroomActiveMembersPanel(widget.classroom)
        else if(_index == 1)
          ClassroomHomePanel(widget.classroom)
        else if(_index == 2)
          ClassroomPendingMembersPanel(widget.classroom),
      ],
    );
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
    );
    
    // Close this classroom
    Navigator.of(context).pop();

    // Reset selected room
    widget.resetSelectedRoom(refresh: true);
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

    // Close this room
    Navigator.of(context).pop();

    // Refresh UI
    widget.reloadAndOpenRoom();
  }
}
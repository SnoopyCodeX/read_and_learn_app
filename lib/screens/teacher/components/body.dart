import 'package:flutter/material.dart';
import 'package:flutter_cache/flutter_cache.dart' as Cache;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../../components/rounded_input_field.dart';
import '../../../constants.dart';
import '../../../models/classroom_model.dart';
import '../../../models/result_model.dart';
import '../../../models/user_model.dart';
import '../../../services/classroom_services.dart';
import '../../../utils/utils.dart';
import '../settings/settings_panel.dart';
import 'classroom_list.dart';
import 'navbar.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
	TextEditingController? _nameController, _sectionController;
  String? _name, _section;
  User? _user;

  @override
  void initState() {
    super.initState();

		_nameController = TextEditingController();
		_sectionController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    super.dispose();

    _user = null;
		_nameController!.dispose();
		_sectionController!.dispose();
  }

  Future<void> _loadUserData() async {
    Map<String, dynamic> json = await Cache.load('user', <String, dynamic>{});
    _user = User.fromJson(json);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _user != null 
          ? CustomNavBar(
              user: _user!, 
              icon: Icons.settings_outlined,
              onPressed: () => Navigator
                .of(context)
                .push(MaterialPageRoute(
                  builder: (_) => SettingsPanel(_user!),
                ),
              ),
            )
          : Container(),
        Card(
          color: kPrimaryColor,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(35),
              topRight: Radius.circular(15),
              bottomLeft: Radius.circular(35),
              bottomRight: Radius.circular(35),
            ),
          ),
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.86,
                height: 200,
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 10,
                  right: 22,
                  bottom: 0,
                ),
                child: Opacity(
                  opacity: 0.6,
                  child: Container(
                    padding: const EdgeInsets.only(
                      top: 72.8,
                      left: 120,
                    ),
                    child: SvgPicture.asset(
                      "images/illustrations/create_class.svg",
                      colorBlendMode: BlendMode.dstATop,
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 30,
                    ),
                    child: Text(
                      'Want to start a class?',
                      style: GoogleFonts.poppins(
                        color: kPrimaryLightColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 30,
                    ),
                    child: Text(
                      'Create a\nclass now',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 26,
                        height: 1, 
                      ),
                      strutStyle: StrutStyle(height: 0),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 30,
                    ),
                    child: MaterialButton(
                      child: Text(
                        'Create class',
                        style: GoogleFonts.poppins(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      onPressed: () => _showCreateClassBottomSheet(),
                      color: Colors.white,
                      elevation: 4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 14,
          ),
          child: Row(
            children: [
              Text(
                'Your Classes',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              Spacer(),
              InkWell(
                onTap: () {
                  setState(() {});
                },
                borderRadius: BorderRadius.all(Radius.circular(14)),
                child: Container(
                  child: Icon(Icons.refresh_outlined, color: kPrimaryColor),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(14)), 
                    border: Border.all(
                      color: kPrimaryLightColor,
                      width: 2,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        _user != null
          ? ClassroomList(_user!)
          : Container(),
      ],
    );
  }

  void _showCreateClassBottomSheet() {
    Utils.showCustomAlertDialog(
			context: context,
			content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create a class',
              style: GoogleFonts.poppins(
                color: kPrimaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 22,
              ),
            ),
            SizedBox(height: 10),
            RoundedInputField(
              icon: Icons.card_membership_outlined,
              defaultValue: _name ?? '',
							controller: _nameController,
              hintText: 'Name', 
              onChanged: (string) {
                _name = string;
              }
            ),
            SizedBox(height: 10),
            RoundedInputField(
              icon: Icons.cast_for_education_outlined,
              defaultValue: _section ?? '',
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
          onPressed: () => _createClass(),
          child: Text(
            'Create',
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

  Future<void> _createClass() async {
    if(_name == null || _section == null || _name!.isEmpty || _section!.isEmpty)
      Utils.showAlertDialog(
        context: context,
        title: 'Create Failed',
        message: 'Please fill in the required fields before continuing.',
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(), 
            child: Text(
              'Okay',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      );
    else {
      // Close custom dialog
      Navigator.of(context, rootNavigator: true).pop();

      String uid = Uuid().v4();
      Classroom classroom = Classroom(
        id: uid, 
        name: _name!, 
        section: _section!, 
        code: uid, 
        teacher: _user!.id,
      );

			// Reset variables
			_name = null;
			_section = null;

			// Reset controllers
			_nameController!.text = '';
			_sectionController!.text = '';

      // Show progress dialog
      Utils.showProgressDialog(
        context: context, 
        message: 'Creating class...'
      );

      // Send create request to db
      Result<void> result = await ClassroomService.instance.setClassroom(classroom);

      // Dismiss progress dialog
      Navigator.of(context, rootNavigator: true).pop();

      // Show snackbar
      Utils.showSnackbar(
        context: context,
        message: result.message, 
        actionLabel: 'OK', 
        onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
      );

      // Reload UI
      setState(() {});
    }
  }
}
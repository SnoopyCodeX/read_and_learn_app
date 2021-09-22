import 'package:bottom_bar/bottom_bar.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../models/classroom_model.dart';
import '../../../providers/temp_variables_provider.dart';
import 'components/body.dart';

class ClassroomPanel extends StatefulWidget {
  static const String NAME = '/class_panel';
  
  final void Function({bool refresh}) resetSelectedRoom;
  final void Function() reloadAndOpenRoom;
  final Classroom classroom;

  const ClassroomPanel(this.classroom, this.reloadAndOpenRoom, this.resetSelectedRoom);

  @override
  _ClassroomPanelState createState() => _ClassroomPanelState();
}

class _ClassroomPanelState extends State<ClassroomPanel> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.resetSelectedRoom();
        Navigator.of(context).pop();

        return true;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey.shade100,
          body: ConnectivityWidgetWrapper(
            alignment: Alignment.topCenter,
            disableInteraction: true,
            child: SingleChildScrollView(
              child: Body(widget.classroom, widget.reloadAndOpenRoom, widget.resetSelectedRoom),
            ),
          ),
          bottomNavigationBar: BottomBar(
            backgroundColor: Colors.white,
            selectedIndex: Provider.of<TempVariables>(context, listen: true).tempIndex,
            onTap: (index) => Provider.of<TempVariables>(context, listen: false).setTempIndex(index),
            items: [
              BottomBarItem(
                icon: Icon(Icons.people_outlined),
                title: Text(
                  'Active Members',
                  style: GoogleFonts.poppins(),
                ), 
                activeColor: kPrimaryColor,
                inactiveColor: Colors.black,
              ),
              BottomBarItem(
                icon: Icon(Icons.book_outlined), 
                title: Text(
                  'Stories',
                  style: GoogleFonts.poppins(),
                ), 
                activeColor: kPrimaryColor,
                inactiveColor: Colors.black,
              ),
              BottomBarItem(
                icon: Icon(Icons.pending_outlined), 
                title: Text(
                  'Pending Members',
                  style: GoogleFonts.poppins(),
                ), 
                activeColor: kPrimaryColor,
                inactiveColor: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
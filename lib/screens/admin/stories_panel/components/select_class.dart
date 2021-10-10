import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../constants.dart';
import '../../../../models/classroom_model.dart';
import '../../../../utils/utils.dart';

class SelectClass extends StatefulWidget {
  final void Function(Classroom selectedClass) onClassSelected;
  final List<Classroom> classes;

  const SelectClass({ Key? key, required this.classes, required this.onClassSelected }) : super(key: key);

  @override
  _SelectClassState createState() => _SelectClassState();
}

class _SelectClassState extends State<SelectClass> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(10),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Classrooms',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              if(widget.classes.isNotEmpty) ...[
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.classes.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(
                        widget.classes[index].name,
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      subtitle: Text(
                        widget.classes[index].section,
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontSize: 18,
                        ),
                      ),
                      onTap: () => _confirmSelectedClass(widget.classes[index]),
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: Center(
                    child: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _confirmSelectedClass(Classroom selectedClass) {
    Utils.showAlertDialog(
      context: context, 
      title: "Confirm Action", 
      message: "Are you sure you want to select this class?", 
      actions: [
        TextButton(
          onPressed: () {
            widget.onClassSelected(selectedClass);

            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context).pop();
          }, 
          child: Text(
            'Yes',
            style: GoogleFonts.poppins(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            )
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(), 
          child: Text(
            'No',
            style: GoogleFonts.poppins(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            )
          ),
        ),
      ],
    );
  }
}
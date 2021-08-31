import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../constants.dart';
import '../../../../../models/classroom_model.dart';
import 'components/create_story_form.dart';
import 'components/story_list.dart';

class ClassroomHomePanel extends StatefulWidget {
  final Classroom classroom;
  const ClassroomHomePanel(this.classroom);

  @override
  _ClassroomHomePanelState createState() => _ClassroomHomePanelState();
}

class _ClassroomHomePanelState extends State<ClassroomHomePanel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
                      top: 40,
                      left: 120,
                    ),
                    child: SvgPicture.asset(
                      "images/illustrations/read.svg",
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
                      'Want to add new story?',
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
                      'Create a\nstory now',
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
                        'Create story',
                        style: GoogleFonts.poppins(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CreateStoryForm(),
                          ),
                        );
                      },
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
                'Your Stories',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              Spacer(),
              InkWell(
                onTap: () => setState(() {}),
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
        ClassroomStoryListPanel(widget.classroom.id),
      ],
    );
  }
}
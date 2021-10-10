import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../constants.dart';
import '../../../../../models/classroom_model.dart';
import '../../../../../models/result_model.dart';
import '../../../../../models/user_model.dart';
import '../../../../../services/classroom_member_services.dart';

class ClassroomActiveMembersPanel extends StatefulWidget {
  final Classroom classroom;

  const ClassroomActiveMembersPanel(this.classroom);

  @override
  _ClassroomActiveMembersPanelState createState() => _ClassroomActiveMembersPanelState();
}

class _ClassroomActiveMembersPanelState extends State<ClassroomActiveMembersPanel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Active Members',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        SizedBox(height: 10),
        FutureBuilder(
          future: ClassMemberService.instance.getAllMembers(
            widget.classroom.id,
            pending: false,
          ),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              Result<List<User>?> data = snapshot.data as Result<List<User>?>;

              if(!data.hasError) {
                List<User> users = data.data!;

                return Flexible(
                  fit: FlexFit.loose,
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: users.length,
                    itemBuilder: (context, index) => _buildListTile(users[index]),
                  ),
                );
              }

              return Flexible(
                fit: FlexFit.loose,
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
                          'No members found',
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
            }

            return Flexible(
              fit: FlexFit.loose,
              child: Center(
                 child: Container(
                  child: CircularProgressIndicator(
                    color: kPrimaryColor,
                    strokeWidth: 4,
                  ),
                ),
              ),
            );
          }
        ),
      ],
    );
  }

  Widget _buildListTile(User user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: kPrimaryLightColor,
                backgroundImage: NetworkImage(user.photo),
                radius: 30,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  user.childName,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
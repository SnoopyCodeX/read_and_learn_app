import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../constants.dart';
import '../../../../../models/classroom_model.dart';
import '../../../../../models/result_model.dart';
import '../../../../../models/user_model.dart';
import '../../../../../services/classroom_member_services.dart';
import '../../../../../utils/utils.dart';

class ClassroomPendingMembersPanel extends StatefulWidget {
  final Classroom classroom;

  const ClassroomPendingMembersPanel(this.classroom);

  @override
  _ClassroomPendingMembersPanelState createState() => _ClassroomPendingMembersPanelState();
}

class _ClassroomPendingMembersPanelState extends State<ClassroomPendingMembersPanel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Pending Members',
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
            pending: true,
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Card(
        elevation: 4,
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
              IconButton(
                icon: Icon(
                  Icons.done_all_outlined,
                  color: Colors.green,
                ),
                onPressed: () => _showAcceptChildDialog(user), // Accept student
              ),
              IconButton(
                icon: Icon(
                  Icons.remove_done_outlined,
                  color: Colors.red,
                ),
                onPressed: () => _showDeclineChildDialog(user), // Decline student
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAcceptChildDialog(User user) {
    Utils.showAlertDialog(
      context: context, 
      title: 'Confirm Action', 
      message: 'Do you really want to accept this student to your class?', 
      actions: [
        TextButton(
          child: Text(
            'Yes',
            style: GoogleFonts.poppins(
              color: kPrimaryColor,
              fontSize: 18,
            ),
          ),
          onPressed: () => _acceptUser(user),
        ),
        TextButton(
          child: Text(
            'No',
            style: GoogleFonts.poppins(
              color: kPrimaryColor,
              fontSize: 18,
            ),
          ),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
      ],
    );
  }

  void _showDeclineChildDialog(User user) {
    Utils.showAlertDialog(
      context: context, 
      title: 'Confirm Action', 
      message: 'Do you really want to decline this student from your class?', 
      actions: [
        TextButton(
          child: Text(
            'Yes',
            style: GoogleFonts.poppins(
              color: kPrimaryColor,
              fontSize: 18,
            ),
          ),
          onPressed: () => _declineUser(user),
        ),
        TextButton(
          child: Text(
            'No',
            style: GoogleFonts.poppins(
              color: kPrimaryColor,
              fontSize: 18,
            ),
          ),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
      ],
    );
  }

  Future<void> _acceptUser(User user) async {
    // Dismiss dialog
    Navigator.of(context, rootNavigator: true).pop();

    Utils.showProgressDialog(
      context: context, 
      message: 'Accepting student...'
    );

    await ClassMemberService.instance.acceptMember(widget.classroom.id, user.id);

    // Dismiss progress dialog
    Navigator.of(context, rootNavigator: true).pop();

    Utils.showSnackbar(
      context: context, 
      message: 'Student has been accepted successfully!',
    );

    // Refresh list
    setState(() {});
  }
  Future<void> _declineUser(User user) async {
    // Dismiss dialog
    Navigator.of(context, rootNavigator: true).pop();

    Utils.showProgressDialog(
      context: context, 
      message: 'Declining student...'
    );

    await ClassMemberService.instance.denyOrRemoveMember(widget.classroom.id, user.id);

    // Dismiss progress dialog
    Navigator.of(context, rootNavigator: true).pop();

    Utils.showSnackbar(
      context: context, 
      message: 'Student has been declined successfully!',
    );

    // Refresh list
    setState(() {});
  }
}
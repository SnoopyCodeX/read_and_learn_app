import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../constants.dart';
import '../../../../models/result_model.dart';
import '../../../../models/user_model.dart';
import '../../../../providers/temp_variables_provider.dart';
import '../../../../services/user_services.dart';
import '../../../../utils/utils.dart';
import 'add_edit_teacher.dart';

class TeacherListView extends StatefulWidget {
  final String teacherId;
  const TeacherListView({
      required this.teacherId,
      Key? key 
    }) : super(key: key);

  @override
  _TeacherListViewState createState() => _TeacherListViewState();
}

class _TeacherListViewState extends State<TeacherListView> {

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    Provider.of<TempVariables>(context, listen: false).onSearch = (String query) {
      setState(() {
        _searchQuery = query;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: UserService.instance.getActiveUser("type", 1),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.done && snapshot.hasData)
        {
          Result<List<User>> data = snapshot.data as Result<List<User>>;

          if(!data.hasError)
          {
            List<User> teachers = data.data as List<User>;
            List<User> temp = [...teachers];

            for(User user in temp)
              if(user.id == widget.teacherId) {
                teachers.remove(user);
                break;
              }

            List<User> _searchList = [];
            for(User user in teachers)
              if('${user.firstName} ${user.lastName}'.toLowerCase().contains(_searchQuery.toLowerCase())) {
                _searchList.add(user);
                break;
              }

            if(_searchList.isEmpty && _searchQuery.isNotEmpty)
              return Expanded(
                      child: Center(
                        child: Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.7,
                                  height: 300,
                                  child: SvgPicture.asset("images/illustrations/empty.svg"),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'No teachers found',
                                  style: GoogleFonts.poppins(
                                    color: kPrimaryColor,
                                    letterSpacing: 2,
                                    wordSpacing: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
            
            return Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: StaggeredGridView.countBuilder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        crossAxisCount: 4, 
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        itemCount: _searchList.isNotEmpty && _searchQuery.isNotEmpty
                          ? _searchList.length
                          : teachers.length,
                        staggeredTileBuilder: (index) => StaggeredTile.fit(2),
                        itemBuilder: (context, index) => _buildTeacherCard(
                          _searchList.isNotEmpty && _searchQuery.isNotEmpty
                           ? _searchList[index]
                           : teachers[index], 
                          index + 1,
                        ), 
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Expanded(
            child: Center(
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: 300,
                        child: SvgPicture.asset("images/illustrations/empty.svg"),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'No teachers found',
                        style: GoogleFonts.poppins(
                          color: kPrimaryColor,
                          letterSpacing: 2,
                          wordSpacing: 2,
                        ),
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
                color: Colors.black87,
                strokeWidth: 4,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTeacherCard(User user, int count) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: user.gender.toLowerCase() == 'male' 
          ? Colors.blueAccent.withAlpha(0x20)
          : Colors.pinkAccent.withAlpha(0x20)
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withAlpha(0x80),
            backgroundImage: NetworkImage(user.photo.isEmpty 
                ? "https://magfellow.com/assets/theme/images/team/emily.png"
                : user.photo,
              ),
            radius: 40,
          ),
          SizedBox(height: 8),
          Text(
            "${user.firstName} ${user.lastName.substring(0, 1)}.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.black87,
              height: 1,
            ),
          ),
          Text(
            "${user.gender}",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 14),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildRoundedTinyButton(name: 'Edit', onPressed: () => _showEditDialog(user)),
              _buildRoundedTinyButton(name: 'Delete', onPressed: () => _showDeleteDialog(user)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedTinyButton({
    required String name, 
    required void Function() onPressed,
  }) {
    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      elevation: 0,
      focusElevation: 0,
      highlightElevation: 0,
      disabledElevation: 0,
      color: Colors.white.withAlpha(0x80),
      clipBehavior: Clip.antiAlias,
      onPressed: () => onPressed(),
      child: Text(
        name,
        style: GoogleFonts.poppins(),
      ),
    );
  }

  void _showDeleteDialog(User user) {
    Utils.showAlertDialog(
      context: context, 
      title: 'Confirm Action', 
      message: 'Do you really want to delete this teacher?', 
      actions: [
        TextButton(
          onPressed: () => _deleteTeacher(user), 
          child: Text(
            'Yes',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(), 
          child: Text(
            'No',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
        ),
      ],
    );
  }

  void _showEditDialog(User user) {
    Utils.showAlertDialog(
      context: context, 
      title: 'Confirm Action', 
      message: 'Do you really want to edit this teacher?', 
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddEditTeacherScreen(
                  user: user,
                  refreshList: () => setState(() {}),
                ),
              ),
            );
          },
          child: Text(
            'Yes',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(), 
          child: Text(
            'No',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _deleteTeacher(User user) async {
    Navigator.of(context, rootNavigator: true).pop();

    Utils.showProgressDialog(
      context: context, 
      message: 'Deleting teacher...',
    );

    await UserService.instance.deleteUser(user);

    Navigator.of(context, rootNavigator: true).pop();

    Utils.showSnackbar(
      context: context, 
      message: 'Teacher has been successfully deleted!',
    );

    // Refresh list
    setState(() {});
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants.dart';
import '../../../models/classroom_model.dart';
import '../../../models/result_model.dart';
import '../../../models/user_model.dart';
import '../../../services/classroom_services.dart';
import 'classroom_list_item.dart';

class ClassroomList extends StatefulWidget {
  final void Function() refreshListener;
  final User user;

  const ClassroomList(this.user, this.refreshListener);

  @override
  _ClassroomListState createState() => _ClassroomListState();
}

class _ClassroomListState extends State<ClassroomList> {
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
                  itemBuilder: (context, index) => ClassroomListItem(
                    classroom: classrooms[index],
                    user: widget.user, 
                    refreshListener: widget.refreshListener,
                  ),
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
}
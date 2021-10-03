import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../constants.dart';
import '../../../../../../models/result_model.dart';
import '../../../../../../models/story_model.dart';
import '../../../../../../models/user_progress_model.dart';
import '../../../../../../services/user_progress_services.dart';

class PendingStudentScreen extends StatefulWidget {
  final Story story;

  const PendingStudentScreen(this.story);

  @override
  _PendingStudentScreenState createState() => _PendingStudentScreenState();
}

class _PendingStudentScreenState extends State<PendingStudentScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Pending Students',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          FutureBuilder(
            future: UserProgressService.instance.getAllNotFinished(widget.story.classroom, widget.story.id),
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                Result<List<UserProgress>?> data = snapshot.data as Result<List<UserProgress>?>;

                if(!data.hasError) {
                  List<UserProgress> userProgresses = data.data!;

                  return Flexible(
                    fit: FlexFit.loose,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: userProgresses.length,
                      itemBuilder: (context, index) => _buildListTile(userProgresses[index]),
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
                            'No students found',
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
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(UserProgress userProgress) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userProgress.name,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Started on: ${userProgress.dateStarted}',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                ),
              ),
              Text(
                'Finished on: (Not finished yet)',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                ),
              ),
              Text(
                'Accuracy: ${userProgress.accuracy}%',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                ),
              ),
              Text(
                'Speed: ${userProgress.speed} wpm',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
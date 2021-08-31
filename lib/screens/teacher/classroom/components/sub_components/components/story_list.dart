import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../constants.dart';
import '../../../../../../models/result_model.dart';
import '../../../../../../models/story_model.dart';
import '../../../../../../services/story_services.dart';

class ClassroomStoryListPanel extends StatefulWidget {
  final String classId;

  const ClassroomStoryListPanel(this.classId);

  @override
  _ClassroomStoryListPanelState createState() => _ClassroomStoryListPanelState();
}

class _ClassroomStoryListPanelState extends State<ClassroomStoryListPanel> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: StoryService.instance.getStory('class_id', widget.classId),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          Result<List<Story>> data = snapshot.data as Result<List<Story>>;

          if(!data.hasError) {
            List<Story> stories = data.data as List<Story>;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: StaggeredGridView.countBuilder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 4, 
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    staggeredTileBuilder: (index) => StaggeredTile.fit(1),
                    itemBuilder: (context, index) => _buildStoryCard(stories[index]),
                  ),
                ),
              ],
            );
          }

          return Center(
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
                    'No stories found',
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
    );
  }

  Widget _buildStoryCard(Story story) {
    return Container(
      child: InkWell(
        onTap: () {}, // TODO: Open story
        borderRadius: BorderRadius.circular(10),
        child: Card(
          elevation: 5,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(story.thumbnail),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    story.title,
                    style: GoogleFonts.poppins(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../../../constants.dart';
import '../../../../../../models/result_model.dart';
import '../../../../../../models/story_model.dart';
import '../../../../../../providers/temp_variables_provider.dart';
import '../../../../../../services/story_services.dart';
import '../../../story/story_screen.dart';

class ClassroomStoryListPanel extends StatefulWidget {
  final String classId;

  const ClassroomStoryListPanel(this.classId);

  @override
  _ClassroomStoryListPanelState createState() => _ClassroomStoryListPanelState();
}

class _ClassroomStoryListPanelState extends State<ClassroomStoryListPanel> {
  Story? _story;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: StoryService.instance.getStory('classroom', widget.classId),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          Result<List<Story>> data = snapshot.data as Result<List<Story>>;

          if(!data.hasError) {
            List<Story> stories = data.data as List<Story>;

            WidgetsBinding.instance!.addPostFrameCallback((_) { 
              if(_story != null)
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StoryScreen(
                      _story!, 
                      () => _refreshStoryList(), 
                      (_) => _openStory(_),
                      () => _resetOpenedStory(),
                    ),
                  ),
                );
            });

            return Container(
              width: MediaQuery.of(context).size.width * 0.86,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: StaggeredGridView.countBuilder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 4, 
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 1,
                      itemCount: stories.length,
                      staggeredTileBuilder: (index) => StaggeredTile.fit(2),
                      itemBuilder: (context, index) => _buildStoryCard(stories[index]),
                    ),
                  ),
                ],
              ),
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
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => StoryScreen(
              story, 
              () => _refreshStoryList(), 
              (_) => _openStory(_),
              () => _resetOpenedStory(),
            ),
          ),
        ),
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
                  height: 160,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(story.thumbnail),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          story.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _refreshStoryList() {
    setState(() {});
  }

  void _resetOpenedStory() {
    _story = null;
    Provider.of<TempVariables>(context, listen: false).setTempStoryIndex(1);
  }

  void _openStory(Story story) {
    setState(() {
      _story = story;
    });
  }
}
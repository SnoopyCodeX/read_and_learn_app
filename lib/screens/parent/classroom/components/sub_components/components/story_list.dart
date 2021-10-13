import 'package:flutter/material.dart';
import 'package:flutter_cache/flutter_cache.dart' as Cache;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../../../constants.dart';
import '../../../../../../models/result_model.dart';
import '../../../../../../models/story_model.dart';
import '../../../../../../models/user_progress_model.dart';
import '../../../../../../providers/temp_variables_provider.dart';
import '../../../../../../services/story_services.dart';
import '../../../../../../services/user_progress_services.dart';
import '../../../../../../utils/utils.dart';
import '../../../story/story_screen.dart';

class ClassroomStoryListPanel extends StatefulWidget {
  final String classId;

  const ClassroomStoryListPanel(this.classId);

  @override
  _ClassroomStoryListPanelState createState() => _ClassroomStoryListPanelState();
}

class _ClassroomStoryListPanelState extends State<ClassroomStoryListPanel> {
  List<bool> unlockedStories = [];
  Story? _story;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getStories(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          Result<List<Story>> data = snapshot.data as Result<List<Story>>;

          if(!data.hasError) {
            List<Story> stories = data.data as List<Story>;
            print('Stories: ${stories.length}');

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

            if(stories.length <= 0)
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
                      itemBuilder: (context, index) => _buildStoryCard(stories[index], unlockedStories[index]),
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
        else if(snapshot.connectionState == ConnectionState.done && !snapshot.hasData)
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

  Widget _buildStoryCard(Story story, bool isUnlocked) {
    return Container(
      child: InkWell(
        onTap: () {
          if(isUnlocked)
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => StoryScreen(
                  story, 
                  () => _refreshStoryList(), 
                  (_) => _openStory(_),
                  () => _resetOpenedStory(),
                ),
              ),
            );
          else
            Utils.showSnackbar(
              context: context, 
              message: 'Finish the other story first to unlock the next story.',
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
        },
        borderRadius: BorderRadius.circular(10),
        child: Opacity(
          opacity: isUnlocked ? 1.0 : 0.6,
          child: Card(
            elevation: isUnlocked ? 5 : 1.8,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
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
                  isUnlocked
                  ? Container()
                  : Icon(
                      Icons.lock_outlined, 
                      color: Colors.black,
                      size: 80,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<Result<List<Story>>> _getStories() async {
    Map<String, dynamic> userData = await Cache.load('user', <String, dynamic>{});
    Result<List<Story>> stories = await StoryService.instance.getStory('classroom', widget.classId);
    Result<List<UserProgress>?> progresses = await UserProgressService.instance.getAllFinishedProgress(widget.classId, userData['id']);
    unlockedStories = [];

    if(!stories.hasError) {
      if(!progresses.hasError) {
        print('Progress Count: ${(progresses.data as List<UserProgress>).length}');

        // Lock all stories by default
        // ignore: unused_local_variable
        for(Story story in stories.data!)
          unlockedStories.add(false);

        // Records all locked and unlocked stories
        int _unlockedIndex = 0;
        for(int i = 0; i < progresses.data!.length; i++) {
          for(int j = 0; j < stories.data!.length; j++)
            if(progresses.data![i].storyId == stories.data![j].id)
              unlockedStories[_unlockedIndex++] = true;
        }

        // Unlock next story
        if(unlockedStories.contains(true)) {
          // Find the index of the last unlocked story
          bool stop = false;
          for(int prev = 0; prev < unlockedStories.length; prev++) {
            // Stop whole loop
            if(stop)
              break;

            // Unlock the next story if the previous story is already unlocked
            for(int next = prev + 1; next < unlockedStories.length; next++)
              if(unlockedStories[prev] && !unlockedStories[next]) {
                unlockedStories[next] = true;
                stop = true;
                break;
              }
          }
        }
      }
      else {
        // ignore: unused_local_variable
        for(Story story in stories.data!)
          unlockedStories.add(false);

        // Unlock the first story by default
        if(unlockedStories.isNotEmpty)
          unlockedStories[0] = true;
      }
    } else {
      // ignore: unused_local_variable
      for(Story story in stories.data!)
        unlockedStories.add(false);

      // Unlock the first story by default
      if(unlockedStories.isNotEmpty)
        unlockedStories[0] = true;
    }
    
    return stories;
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
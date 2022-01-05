import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../../../constants.dart';
import '../../../../../../models/result_model.dart';
import '../../../../../../models/story_model.dart';
import '../../../../../../services/story_services.dart';
import '../../../../providers/temp_variables_provider.dart';
import 'add_edit_story.dart';

class StoryListView extends StatefulWidget {
  const StoryListView();

  @override
  _StoryListViewState createState() => _StoryListViewState();
}

class _StoryListViewState extends State<StoryListView> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    Provider.of<TempVariables>(context, listen: false).onSearch = (query) {
      setState(() {
        _searchQuery = query;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: StoryService.instance.getAllStories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            Result<List<Story>> data = snapshot.data as Result<List<Story>>;

            if (!data.hasError) {
              List<Story> stories = data.data as List<Story>;
              List<Story> _searchList = [];

              for (Story story in stories)
                if (story.title
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ||
                    story.authorName
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                  _searchList.add(story);

              if (_searchList.isEmpty && _searchQuery.isNotEmpty)
                return Expanded(
                  child: Center(
                    child: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: 300,
                            child: SvgPicture.asset(
                                "images/illustrations/empty.svg"),
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
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 1,
                          itemCount:
                              _searchList.isNotEmpty && _searchQuery.isNotEmpty
                                  ? _searchList.length
                                  : stories.length,
                          staggeredTileBuilder: (index) => StaggeredTile.fit(2),
                          itemBuilder: (context, index) => _buildStoryCard(
                            _searchList.isNotEmpty && _searchQuery.isNotEmpty
                                ? _searchList[index]
                                : stories[index],
                          ),
                        ),
                      ),
                    ],
                  ),
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
          } else if (snapshot.connectionState == ConnectionState.done &&
              !snapshot.hasData)
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
                  color: Colors.black87,
                  strokeWidth: 4,
                ),
              ),
            ),
          );
        });
  }

  Widget _buildStoryCard(Story story) {
    return Container(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddEditStoryScreen(
              story: story,
              refreshList: () => _refreshStoryList(),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            'Author: ',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 10),
                          Expanded(
                            child: Text(
                              story.authorName,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Class: ',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 10),
                          Expanded(
                            child: Text(
                              story.classroomName,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
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
}

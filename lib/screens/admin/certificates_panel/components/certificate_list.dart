import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../constants.dart';
import '../../../../models/result_model.dart';
import '../../../../models/user_progress_model.dart';
import '../../../../providers/temp_variables_provider.dart';
import '../../../../services/user_progress_services.dart';

class CertificateListView extends StatefulWidget {
  const CertificateListView({Key? key}) : super(key: key);

  @override
  _CertificateListViewState createState() => _CertificateListViewState();
}

class _CertificateListViewState extends State<CertificateListView> {

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
      future: UserProgressService.instance.getProgress("status", STATUS_FINISHED_READING),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.done && snapshot.hasData)
        {
          Result<List<UserProgress>?> data = snapshot.data as Result<List<UserProgress>?>;

          if(!data.hasError)
          {
            List<UserProgress> certHolders = data.data as List<UserProgress>;

            List<UserProgress> _searchList = [];
            for(UserProgress certHolder in certHolders)
              if('${certHolder.name}'.toLowerCase().contains(_searchQuery.toLowerCase())) {
                _searchList.add(certHolder);
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
                                  'No students found',
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
                          : certHolders.length,
                        staggeredTileBuilder: (index) => StaggeredTile.fit(2),
                        itemBuilder: (context, index) => _buildCertificateCard(
                          _searchList.isNotEmpty && _searchQuery.isNotEmpty
                           ? _searchList[index]
                           : certHolders[index], 
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
                        'No students found',
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

  Widget _buildCertificateCard(UserProgress user, int count) {
    List<String> _user = user.name.split(" ");

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: count.isEven 
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
            backgroundImage: NetworkImage("https://magfellow.com/assets/theme/images/team/emily.png"),
            radius: 40,
          ),
          SizedBox(height: 8),
          Text(
            "${_user[0]} ${_user[1].substring(0, 1)}.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.black87,
              height: 1,
            ),
          ),
          Text(
            "Accuracy: ${user.accuracy}%",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
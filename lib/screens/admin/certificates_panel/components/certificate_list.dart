import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../constants.dart';
import '../../../../models/certificate_holder_model.dart';
import '../../../../models/result_model.dart';
import '../../../../providers/temp_variables_provider.dart';
import '../../../../services/certificate_holder_services.dart';

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

    Provider.of<TempVariables>(context, listen: false).onSearch =
        (String query) {
      setState(() {
        _searchQuery = query;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: CertificateHolderService.instance.getAllCertificateHolders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          Result<List<CertificateHolder>> data =
              snapshot.data as Result<List<CertificateHolder>>;

          if (!data.hasError) {
            List<CertificateHolder> certHolders =
                data.data as List<CertificateHolder>;

            List<CertificateHolder> _searchList = [];
            for (CertificateHolder holder in certHolders) {
              if (holder.userName
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase())) {
                _searchList.add(holder);
                break;
              }
            }

            if (_searchList.isEmpty && _searchQuery.isNotEmpty)
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
                            child: SvgPicture.asset(
                                "images/illustrations/empty.svg"),
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
                        itemCount:
                            _searchList.isNotEmpty && _searchQuery.isNotEmpty
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
                        child:
                            SvgPicture.asset("images/illustrations/empty.svg"),
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

  Widget _buildCertificateCard(CertificateHolder holder, int count) {
    List<String> username = holder.userName.split(' ');

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          color: count.isEven
              ? Colors.blueAccent.withAlpha(0x20)
              : Colors.pinkAccent.withAlpha(0x20)),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withAlpha(0x80),
            backgroundImage: NetworkImage(
                "http://clipart-library.com/images_k/graduate-silhouette-vector/graduate-silhouette-vector-19.png"),
            radius: 40,
          ),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "${username[username.length - 1]}, ${username[0].substring(0, 1)}.",
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.black87,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "Teacher: ${holder.teacherName}",
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "Class: ${holder.classroomName}",
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "Age: ${holder.age} years old",
                  textAlign: TextAlign.start,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

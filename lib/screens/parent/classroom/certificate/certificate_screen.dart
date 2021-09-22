import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_cache/flutter_cache.dart' as Cache;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:jiffy/jiffy.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../models/classroom_model.dart';
import '../../../../models/result_model.dart';
import '../../../../models/story_model.dart';
import '../../../../models/user_progress_model.dart';
import '../../../../services/story_services.dart';
import '../../../../services/user_progress_services.dart';
import '../../../../utils/utils.dart';
import '../components/widget_to_image.dart';

class CertificateScreen extends StatefulWidget {
  final Classroom classroom;

  const CertificateScreen(this.classroom, { Key? key}) : super(key: key);

  @override
  _CertificateScreenState createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  Map<String, dynamic> userData = {};
  GlobalKey? certificateKey;
  bool locked = true;

  @override
  void initState() {
    super.initState();

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      userData = await Cache.load('user', <String, dynamic>{});
      await _isCertificateLocked();
    });
  }

  @override
  Widget build(BuildContext context) {
    String fancyDay = Jiffy(DateTime.now()).format("do");

    if(int.parse(fancyDay.substring(0, fancyDay.length-2)) < 10)
      fancyDay = "0" + fancyDay;
  
    return Center(
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '🎉Certificate of Completion🎉',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.86,
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          WidgetToImage(
                            builder: (key) {
                              this.certificateKey = key;
          
                              return Opacity(
                                opacity: locked ? 0.6 : 1.0,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.86,
                                      height: 220,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          alignment: Alignment.center,
                                          fit: BoxFit.fitWidth,
                                          image: AssetImage('images/certificate/certificate.png'),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 80,
                                      child: Text(
                                        userData['child_name'] ?? '',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 128,
                                      left: 113,
                                      child: Text(
                                        fancyDay,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 128,
                                      left: 164,
                                      child: Text(
                                        Jiffy(DateTime.now()).format("MMM"),
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 128,
                                      left: 240,
                                      child: Text(
                                        Jiffy(DateTime.now()).format("yyyy"),
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 148,
                                      left: 178,
                                      child: Text(
                                        'Read and Learn',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    locked 
                                      ? Icon(
                                        Icons.lock_outlined,
                                        color: Colors.black,
                                        size: 90,
                                      )
                                      : Container(),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minWidth: MediaQuery.of(context).size.width * 0.86,
                    color: locked ? Colors.grey : Colors.green,
                    onPressed: () => _saveCertificate(),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Save certificate',
                        style: GoogleFonts.poppins(
                          color: locked ? Colors.black54 : Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCertificate() async {
    if(locked)
      return;

    Uint8List pngBytes = (await Utils.capture(certificateKey))!;
    var status = await Permission.storage.request();

    if(status == PermissionStatus.granted)
    {
      Utils.showProgressDialog(
        context: context, 
        message: 'Saving certificate...',
      );

      await ImageGallerySaver.saveImage(
        pngBytes,
        name: '${userData['child_name']} certificate',
      );

      Navigator.of(context, rootNavigator: true).pop();

      Utils.showSnackbar(
        context: context, 
        message: 'Certificate has been saved to your gallery!',
      );

      return;
    }
  }

  Future<void> _isCertificateLocked() async {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      Utils.showProgressDialog(
        context: context, 
        message: 'Loading...',
      );

      Result<List<UserProgress>?> userProgressResult = await UserProgressService.instance.getAllFinishedProgress(
        widget.classroom.id, 
        userData['id'],
      );
      Result<List<Story>?> storyResult = await StoryService.instance.getStory(
        'classroom', 
        widget.classroom.id,
      );

      Navigator.of(context, rootNavigator: true).pop();

      if(userProgressResult.hasError)
        setState(() {
          locked = true;
        });
      else {
        List<UserProgress> userProgress = userProgressResult.data as List<UserProgress>;
        List<Story> stories = storyResult.data as List<Story>;

        setState(() {
          locked = (userProgress.length == stories.length);
        });
      }
    });
  }
}
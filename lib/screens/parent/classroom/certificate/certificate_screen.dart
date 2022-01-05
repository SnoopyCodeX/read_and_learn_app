import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_cache/flutter_cache.dart' as Cache;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:jiffy/jiffy.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../../../../models/certificate_holder_model.dart';
import '../../../../models/classroom_model.dart';
import '../../../../models/result_model.dart';
import '../../../../models/story_model.dart';
import '../../../../models/user_model.dart';
import '../../../../models/user_progress_model.dart';
import '../../../../services/certificate_holder_services.dart';
import '../../../../services/story_services.dart';
import '../../../../services/user_progress_services.dart';
import '../../../../services/user_services.dart';
import '../../../../utils/utils.dart';
import '../components/widget_to_image.dart';

class CertificateScreen extends StatefulWidget {
  final Classroom classroom;

  const CertificateScreen(this.classroom, {Key? key}) : super(key: key);

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
    return Center(
      child: Column(
        children: [
          Card(
            elevation: 1,
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
                      elevation: 1,
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
                                  children: [
                                    LayoutBuilder(
                                      builder: (context, constraint) {
                                        double width = constraint.maxWidth;
                                        double height = 220;

                                        return Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              width: width,
                                              height: height,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  alignment: Alignment.center,
                                                  fit: BoxFit.fill,
                                                  image: AssetImage(
                                                    'images/certificate/certificate.png',
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              left: 0,
                                              right: 0,
                                              top: (height / 2) * 0.78,
                                              child: Text(
                                                userData['child_name'] ?? '',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              right: (width / 2) * 0.51,
                                              left: 0,
                                              top: (height / 2) +
                                                  ((height / 2) * 0.17),
                                              child: Text(
                                                Jiffy(DateTime.now())
                                                    .format("do"),
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              left: (width / 2) * 0.1,
                                              right: 0,
                                              top: (height / 2) +
                                                  ((height / 2) * 0.16),
                                              child: Text(
                                                Jiffy(DateTime.now())
                                                    .format('MMM'),
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              left: (width / 2) + 2.8,
                                              right: 0,
                                              top: (height / 2) +
                                                  ((height / 2) * 0.17),
                                              child: Text(
                                                Jiffy(DateTime.now())
                                                    .format('yyyy'),
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              left: (width / 2) * 0.75,
                                              right: 0,
                                              top: (height / 2) +
                                                  ((height / 2) * 0.36),
                                              child: Text(
                                                'Read and Learn',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            if (locked)
                                              Icon(
                                                Icons.lock_outlined,
                                                color: Colors.black,
                                                size: 90,
                                              )
                                            else
                                              Container(),
                                          ],
                                        );
                                      },
                                    ),
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
    if (locked) {
      Utils.showSnackbar(
        context: context,
        message:
            'Finish reading all the stories first to unlock your certificate.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    Uint8List pngBytes = (await Utils.capture(certificateKey))!;
    var status = await Permission.storage.request();

    if (status == PermissionStatus.granted) {
      Utils.showProgressDialog(
          context: context, message: 'Saving certificate...');

      Result<CertificateHolder?> result = await CertificateHolderService
          .instance
          .getCertificateHolder(widget.classroom.id, userData['id']);

      if (result.hasError) {
        Result<List<User>> _result = await UserService.instance.getUser(
          'id',
          widget.classroom.teacher,
        );

        CertificateHolder holder = CertificateHolder(
          id: Uuid().v4(),
          userId: userData['id'],
          teacherId: widget.classroom.teacher,
          classroomId: widget.classroom.id,
          age: userData['child_age'],
          userName: "${userData['child_name']}",
          teacherName:
              "${(_result.data as List<User>)[0].gender.toLowerCase() == 'male' ? 'Mr.' : 'Ms.'} ${(_result.data as List<User>)[0].lastName}, ${(_result.data as List<User>)[0].firstName}",
          classroomName: widget.classroom.section,
          dateAcquired: Jiffy(DateTime.now()).format("MMM dd yyyy hh:mm:ss a"),
        );

        await CertificateHolderService.instance.addNewCertificateHolder(holder);
      }

      await ImageGallerySaver.saveImage(
        pngBytes,
        name: '${userData['child_name']} certificate',
      );

      Navigator.of(context, rootNavigator: true).pop();

      Utils.showSnackbar(
        context: context,
        message: 'Certificate has been saved to your gallery!',
        backgroundColor: Colors.green,
        textColor: Colors.white,
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

      Result<List<UserProgress>?> userProgressResult =
          await UserProgressService.instance.getAllFinishedProgress(
        widget.classroom.id,
        userData['id'],
      );
      Result<List<Story>?> storyResult = await StoryService.instance.getStory(
        'classroom',
        widget.classroom.id,
      );

      Navigator.of(context, rootNavigator: true).pop();

      if (userProgressResult.hasError || storyResult.hasError)
        setState(() {
          locked = true;
        });
      else {
        List<UserProgress> userProgress =
            userProgressResult.data as List<UserProgress>;
        List<Story> stories = storyResult.data as List<Story>;

        setState(() {
          locked = !(userProgress.length == stories.length);
        });
      }
    });
  }
}

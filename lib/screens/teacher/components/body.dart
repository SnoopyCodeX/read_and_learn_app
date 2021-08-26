import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_cache/flutter_cache.dart' as Cache;

import '../../../constants.dart';
import '../../../models/user_model.dart';
import '../settings/settings_panel.dart';
import 'classroom_list.dart';
import 'navbar.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  User? _user;

  @override
  void initState() {
    super.initState();

    _loadUserData();
  }

  @override
  void dispose() {
    super.dispose();

    _user = null;
  }

  Future<void> _loadUserData() async {
    Map<String, dynamic> json = await Cache.load('user', <String, dynamic>{});
    _user = User.fromJson(json);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomNavBar(
          user: _user as User, 
          icon: Icons.settings_outlined,
          onPressed: () => Navigator
            .of(context)
            .push(MaterialPageRoute(
              builder: (_) => SettingsPanel(),
            ),
          ),
        ),
        Card(
          color: kPrimaryColor,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(35),
              topRight: Radius.circular(15),
              bottomLeft: Radius.circular(35),
              bottomRight: Radius.circular(35),
            ),
          ),
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.86,
                height: 200,
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 10,
                  right: 22,
                  bottom: 0,
                ),
                child: Opacity(
                  opacity: 0.6,
                  child: Container(
                    padding: const EdgeInsets.only(
                      top: 72.8,
                      left: 120,
                    ),
                    child: SvgPicture.asset(
                      "images/illustrations/create_class.svg",
                      colorBlendMode: BlendMode.dstATop,
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 30,
                    ),
                    child: Text(
                      'Want to start a class?',
                      style: GoogleFonts.poppins(
                        color: kPrimaryLightColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 30,
                    ),
                    child: Text(
                      'Create a\nclass now',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 26,
                        height: 1, 
                      ),
                      strutStyle: StrutStyle(height: 0),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 30,
                    ),
                    child: MaterialButton(
                      child: Text(
                        'Create class',
                        style: GoogleFonts.poppins(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      onPressed: () {},
                      color: Colors.white,
                      elevation: 4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 14,
          ),
          child: Row(
            children: [
              Text(
                'Your Classes',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              Spacer(),
              InkWell(
                onTap: () {
                  setState(() {});
                },
                borderRadius: BorderRadius.all(Radius.circular(14)),
                child: Container(
                  child: Icon(Icons.refresh_outlined, color: kPrimaryColor),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(14)), 
                    border: Border.all(
                      color: kPrimaryLightColor,
                      width: 2,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        ClassroomList(_user!),
      ],
    );
  }
}
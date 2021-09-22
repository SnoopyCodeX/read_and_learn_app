import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants.dart';
import '../../../models/user_model.dart';

class CustomNavBar extends StatefulWidget {
  final void Function() onPressed;
  final User user;
  final IconData icon;

  const CustomNavBar({
    required this.user,
    required this.icon,
    required this.onPressed,
  });

  @override
  _CustomNavBarState createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Shimmer.fromColors(
                    child: Container(
                      width: 50,
                      height: 50,
                      color: Colors.white,
                    ), 
                    baseColor: kBaseColor, 
                    highlightColor: kHighlightColor,
                  ),
                ),
                FadeInImage.memoryNetwork(
                  width: 50,
                  height: 50,
                  placeholder: kTransparentImage, 
                  image: widget.user.photo,
                ),
              ],
            ),
          ),
          SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                (widget.user.gender.toLowerCase() == 'male' 
                  ? 'Mr. '
                  : 'Mrs. ') + '${widget.user.firstName}',
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                widget.user.lastName,
                textAlign: TextAlign.start,
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          Spacer(),
          InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.all(Radius.circular(14)),
            child: Container(
              child: Icon(widget.icon, color: kPrimaryColor),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(14)), 
                border: Border.all(
                  color: kPrimaryLightColor,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
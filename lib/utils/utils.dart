import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants.dart';

class Utils {
  static String bytesToString(Uint8List bytes) {
    StringBuffer buffer = new StringBuffer();
    for (int i = 0; i < bytes.length;) {
      int firstWord = (bytes[i] << 8) + bytes[i + 1];
      if (0xD800 <= firstWord && firstWord <= 0xDBFF) {
        int secondWord = (bytes[i + 2] << 8) + bytes[i + 3];
        buffer.writeCharCode(
            ((firstWord - 0xD800) << 10) + (secondWord - 0xDC00) + 0x10000);
        i += 4;
      } else {
        buffer.writeCharCode(firstWord);
        i += 2;
      }
    }

    return buffer.toString();
  }

  ///
  /// Add a [char] at a [position] with the given String [s].
  ///
  /// The boolean [repeat] defines whether to add the [char] at every [position].
  /// If [position] is greater than the length of [s], it will return [s].
  /// If [repeat] is true and [position] is 0, it will return [s].
  ///
  /// Example :
  /// 1234567890 , '-', 3 => 123-4567890
  /// 1234567890 , '-', 3, true => 123-456-789-0
  ///
  /// @source  https://github.com/Ephenodrom/Dart-Basic-Utils/blob/master/lib/src/StringUtils.dart
  ///
  static String addCharAtPosition(String s, String char, int position,
      {bool repeat = false}) {
    if (!repeat) {
      if (s.length < position) return s;

      String before = s.substring(0, position);
      String after = s.substring(position, s.length);
      return before + char + after;
    }

    if (position == 0) return s;

    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && i % position == 0) buffer.write(char);

      buffer.write(String.fromCharCode(s.runes.elementAt(i)));
    }

    return buffer.toString();
  }

  static Uint8List stringToBytes(String source) {
    var list = <int>[];
    source.runes.forEach((rune) {
      if (rune >= 0x10000) {
        rune -= 0x10000;
        int firstWord = (rune >> 10) + 0xD800;
        list.add(firstWord >> 8);
        list.add(firstWord & 0xFF);
        int secondWord = (rune & 0x3FF) + 0xDC00;
        list.add(secondWord >> 8);
        list.add(secondWord & 0xFF);
      } else {
        list.add(rune >> 8);
        list.add(rune & 0xFF);
      }
    });
    Uint8List bytes = Uint8List.fromList(list);

    return bytes;
  }

  static void showAlertDialog({
    required BuildContext context,
    required String title,
    required String message,
    required List<Widget> actions,
    bool dismissable = true,
  }) {
    showDialog(
      context: context,
      barrierDismissible: dismissable,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        actions: actions,
      ),
    );
  }

  static void showCustomAlertDialog({
    required BuildContext context,
    required Widget content,
    required List<Widget> actions,
    String? title,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: title == null
            ? null
            : Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                ),
              ),
        content: content,
        actions: actions,
      ),
    );
  }

  static void showProgressDialog({
    required BuildContext context,
    required String message,
    bool barrierDismissable = false,
    Color progressColor = kPrimaryColor,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissable,
      builder: (context) => AlertDialog(
        content: Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: progressColor,
                strokeWidth: 4,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.poppins(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showSnackbar(
      {required BuildContext context,
      required String message,
      String? actionLabel,
      Color? backgroundColor,
      Color? textColor,
      void Function()? onPressed}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Text(
          message,
          style: GoogleFonts.poppins(
            color: textColor,
          ),
        ),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                onPressed: onPressed!,
              )
            : null,
      ),
    );
  }

  static Future<Uint8List?> capture(GlobalKey? key) async {
    if (key == null) return null;

    RenderRepaintBoundary renderObject =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    ui.Image image = await renderObject.toImage(pixelRatio: 3);
    final ByteData byteData =
        (await image.toByteData(format: ui.ImageByteFormat.png))!;
    final Uint8List pngByteData = byteData.buffer.asUint8List();

    return pngByteData;
  }
}

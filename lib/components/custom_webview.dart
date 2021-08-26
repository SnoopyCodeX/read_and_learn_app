import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants.dart';

class CustomWebView extends StatefulWidget {
  final String url;

  CustomWebView(this.url);

  @override
  _CustomWebViewState createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {
  final FlutterWebviewPlugin _webviewPlugin = FlutterWebviewPlugin();

  @override
  void initState() {
    super.initState();

    _webviewPlugin.onUrlChanged.listen((url) { 
      if(url.contains("#access_token"))
      {
        List<String> params = url.split("access_token=");
        List<String> endParam = params[1].split("&");

        _webviewPlugin.cleanCookies();
        _webviewPlugin.clearCache();
        _webviewPlugin.close();
        Navigator.of(context).pop(endParam[0]);
      }

      if(url.contains("https://www.facebook.com/connect/login_success.html?error=access_denied&error_code=200&error_description=Permissions+error&error_reason=user_denied"))
        Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: widget.url,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Sign Up using Facebook',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
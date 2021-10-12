import 'package:flutter/material.dart';
import 'package:flutter_cache/flutter_cache.dart' as Cache;
import 'package:provider/provider.dart';

import '../../../models/user_model.dart';
import '../../../providers/temp_variables_provider.dart';
import 'components/navbar.dart';
import 'components/settings_body.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({ Key? key }) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  User? _user;

  Future<void> _loadUserData () async {
    Map<String, dynamic> userData = await Cache.load('user', <String, dynamic>{});
    WidgetsBinding.instance!.addPostFrameCallback((_) async { 
      setState(() {
        _user = User.fromJson(userData);
      });
    });
  }

  @override
  void initState() {
    super.initState();

    Provider.of<TempVariables>(context, listen: false).onSettingsUpdated = () {
      setState(() {
        _loadUserData();
      });
    };

    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            children: [
              CustomNavBar(
                _user == null
                  ? "https://magfellow.com/assets/theme/images/team/emily.png"
                  : _user!.photo,
                title: "Settings Panel",
              ),
              SizedBox(height: 20),
              Expanded(
                child: _user == null 
                  ? Container()
                  : SettingsBody(
                      user: _user,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
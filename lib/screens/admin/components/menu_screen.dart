import 'package:flutter/material.dart';
import 'package:flutter_cache/flutter_cache.dart' as Cache;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../models/menu_item_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/temp_variables_provider.dart';
import '../../../utils/utils.dart';
import '../../welcome/welcome_screen.dart';
import 'menu_items.dart';

class AdminMenuScreen extends StatefulWidget {
  final MenuItem currentItem;
  final ValueChanged<MenuItem> onSelectedItem;

  const AdminMenuScreen({ 
    Key? key, 
    required this.currentItem, 
    required this.onSelectedItem, 
  }) : super(key: key);

  @override
  _AdminMenuScreenState createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  User? _user;
  
  @override
  void initState() {
    super.initState();

    print('Menu Screen: initState() called');
    Provider.of<TempVariables>(context, listen: false).onSettingsUpdated = () {
      _loadUserData();
      print('update called');
    };

    _loadUserData();
  }

  Future<void> _loadUserData () async {
    Map<String, dynamic> userData = await Cache.load('user', <String, dynamic>{});
    WidgetsBinding.instance!.addPostFrameCallback((_) { 
      setState(() {
        _user = User.fromJson(userData);
        print('updated');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        backgroundColor: kPrimaryColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 105),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CircleAvatar(
                  backgroundColor: Colors.purpleAccent,
                  backgroundImage: _user != null
                    ? NetworkImage(_user!.photo)
                    : null,
                  radius: 40,
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _user == null 
                    ? ''
                    : '${_user!.firstName} ${_user!.lastName}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 50),
              ...MenuItems.all.map(_buildMenuItem).toList(),
              Spacer(flex: 2),
              Container(
                width: 170,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 50),
                  child: MaterialButton(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                      side: BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock_outlined,
                            size: 24,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Logout',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onPressed: () => _showLogoutDialog(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(MenuItem item) => ListTileTheme(
    selectedColor: Colors.white,
    child: ListTile(
      selectedTileColor: Colors.black26,
      selected: widget.currentItem == item,
      minLeadingWidth: 20,
      leading: Icon(item.icon),
      title: Text(
        item.title,
        style: GoogleFonts.poppins(),
      ),
      onTap: () => widget.onSelectedItem(item),
    ),
  );

  void _showLogoutDialog() {
    Utils.showAlertDialog(
      context: context, 
      title: 'Confirm Logout', 
      message: 'Do you really want to logout?', 
      actions: [
        TextButton(
          onPressed: () => _logoutAccount(), 
          child: Text(
            'Yes',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(), 
          child: Text(
            'No',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _logoutAccount() async {
    Navigator.of(context, rootNavigator: true).pop();

    Utils.showProgressDialog(
      context: context, 
      message: 'Logging out...',
    );

    Cache.clear();

    Navigator.of(context, rootNavigator: true).pop();
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WelcomeScreen(),
      ),
    );
  }
}
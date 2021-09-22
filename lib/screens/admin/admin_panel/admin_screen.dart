import 'package:flutter/material.dart';
import 'package:flutter_cache/flutter_cache.dart' as Cache;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../models/user_model.dart';
import '../../../providers/temp_variables_provider.dart';
import 'components/add_edit_admin.dart';
import 'components/admin_list.dart';
import 'components/navbar.dart';
import 'components/searchbar.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({ Key? key }) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  User? _user;

  @override
  void initState() {
    super.initState();

    _loadUserData();
  }

  Future<void> _loadUserData () async {
    Map<String, dynamic> userData = await Cache.load('user', <String, dynamic>{});
    WidgetsBinding.instance!.addPostFrameCallback((_) { 
      setState(() {
        _user = User.fromJson(userData);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddEditAdminScreen(
              refreshList: () => setState(() {}),
            ),
          ),
        ),
        child: Icon(
          Icons.add_moderator_outlined,
          color: Colors.white,
        ),
        backgroundColor: Colors.black87,
      ),
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
                title: "Admins Panel",
              ),
              SizedBox(height: 40),
              SearchBar(
                onQueryChanged: (query) {
                  if(query.isEmpty)
                    Provider.of<TempVariables>(context, listen: false).onSearch!('');
                }, 
                onSearch: (query) {
                  Provider.of<TempVariables>(context, listen: false).onSearch!(query);
                },
                hint: "Search name...", 
              ),
              SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Admin List',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Spacer(),
                  InkWell(
                    onTap: () => setState(() {}),
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    child: Container(
                      child: Icon(Icons.refresh_outlined),
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(14)), 
                        border: Border.all(
                          color: Colors.black87,
                          width: 1.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              AdminListView(
                adminId: _user != null 
                  ? _user!.id
                  : '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
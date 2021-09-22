import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

import '../../models/menu_item_model.dart';
import 'admin_panel/admin_screen.dart';
import 'certificates_panel/certificate_screen.dart';
import 'components/menu_items.dart';
import 'components/menu_screen.dart';
import 'parent_panel/parent_screen.dart';
import 'stories_panel/story_screen.dart';
import 'teacher_panel/teacher_screen.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({ Key? key }) : super(key: key);

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  ZoomDrawerController zoomDrawerController = ZoomDrawerController();
  MenuItem currentItem = MenuItems.admins;
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(zoomDrawerController.isOpen!()) {
          zoomDrawerController.close!();
          return false;
        }
        
        return true;
      },
      child: ZoomDrawer(
        showShadow: true,
        backgroundColor: Colors.purpleAccent,
        slideWidth: MediaQuery.of(context).size.width * 0.8,
        borderRadius: 24,
        angle: -10,
        style: DrawerStyle.Style1,
        mainScreen: _getScreen(),
        controller: zoomDrawerController,
        menuScreen: Builder(
          builder: (context) => AdminMenuScreen(
            currentItem: currentItem,
            onSelectedItem: (item) {
              setState(() => currentItem = item);
              ZoomDrawer.of(context)!.close();
            },
          ),
        ),
      ),
    );
  }

  Widget _getScreen() {
    switch (currentItem) {
      case MenuItems.admins:
        return AdminScreen();

      case MenuItems.parents:
        return ParentScreen();

      case MenuItems.teachers:
        return TeacherScreen();

      case MenuItems.stories:
        return StoryScreen();

      case MenuItems.certificates:
        return CertificateScreen();

      case MenuItems.settings:
        return Container();

      default:
        return AdminScreen();
    }
  }
}
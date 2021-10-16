import 'package:flutter/material.dart';

import '../../../models/menu_item_model.dart';

class MenuItems {
  static const MenuItem admins = MenuItem('Admins', Icons.add_moderator_outlined);
  static const MenuItem parents = MenuItem('Parents', Icons.people_alt_outlined);
  static const MenuItem teachers = MenuItem('Teachers', Icons.people_outlined);
  static const MenuItem stories = MenuItem('Stories', Icons.menu_book_outlined);
  static const MenuItem certificates = MenuItem('Certificate Holders', Icons.document_scanner_outlined);
  static const MenuItem settings = MenuItem('Settings', Icons.settings_outlined);

  static const List<MenuItem> all = <MenuItem>[
    admins, 
    parents, 
    teachers, 
    stories, 
    certificates,
    settings,
  ];
}
  
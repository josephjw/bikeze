

import 'package:flutter/cupertino.dart';

class DrawerItemModel {
  String title;
  IconData image;
  DrawerItemModel({
    required this.title,
    required this.image,
  });

  String get getTitle => title;

  set setTitle(String title) => this.title = title;

  IconData get getImage => image;

  set setImage(IconData image) => this.image = image;
}

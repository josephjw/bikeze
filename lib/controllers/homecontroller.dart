import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var isDark = false;

  void ChangeTheme(state) {
    if (state == true) {
      isDark = true;
      Get.changeTheme(ThemeData.dark());
    } else {
      isDark = false;
      Get.changeTheme(ThemeData.light());
    }
    update();
  }
}

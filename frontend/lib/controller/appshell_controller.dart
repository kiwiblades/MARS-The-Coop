import 'package:flutter/material.dart';

class AppShellController {
  void onPressedMail(BuildContext context) {
    Navigator.pushNamed( context, '/mailScreen'); //routes to mail screen when clicked
  }
  void onPressedMyCoop (BuildContext context) {
    Navigator.pushNamed(context, '/myCoopScreen'); //navigates to my coop screen when clicked
  }
  void onPressedProfile (BuildContext context) {
    Navigator.pushNamed(context, '/profileScreen');
  }
}

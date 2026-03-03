import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  static const String routeName = '/resetPasswordScreen';
  const ResetPasswordScreen({super.key});
  
  @override
  State<StatefulWidget> createState() {
    return ResetPasswordScreenState();
  }
}

class ResetPasswordScreenState extends State<ResetPasswordScreen> {
  //controller attach
  //model attach

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("reset password screen"),
    );
  }
}
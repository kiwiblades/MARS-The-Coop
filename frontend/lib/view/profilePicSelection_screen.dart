import 'package:flutter/material.dart';

class ProfilePicSelectionScreen extends StatefulWidget {
  static const String routeName = '/profilePicSelectionScreen';
  const ProfilePicSelectionScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return ProfilePicSelectionScreenState();
  }
}

class ProfilePicSelectionScreenState extends State<ProfilePicSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Profile Picture'),
      ),
      body: Container(
        color: Colors.red,
        child: Text('Profile pic selection screen.'),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class AddChatScreen extends StatefulWidget {
  static const String routeName = '/addChatScreen';
  const AddChatScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return AddChatScreenState();
  }
}

class AddChatScreenState extends State<AddChatScreen> {
  //controller
  //form key
  //form controllers
  @override 
  Widget build(BuildContext context) {
    return Container(
      child: Text('Add chat screen'),
    );
  }
}
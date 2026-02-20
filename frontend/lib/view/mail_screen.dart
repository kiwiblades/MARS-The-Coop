import 'package:flutter/material.dart';

class MailScreen extends StatefulWidget {
  static const String routeName = '/mailScreen';
  const MailScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return MailScreenState();
  }
}

class MailScreenState extends State<MailScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Mail screen"),
    );
  }
}

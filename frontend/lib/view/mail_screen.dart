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
  // late MailScreenController controller; //controller to be linked

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Title Test'),
        title: Builder(
          builder: (BuildContext context) {
            return Row(
              children: [
                TextButton(onPressed: () {}, child: const Text('Mail')),
                TextButton(onPressed: () {}, child: const Text('My Coop')),
              ],
            );
          },
        ),
        actions: [
          IconButton(
          icon: const Icon(Icons.person),
          // tooltip: 'Increase volume by 10',
          onPressed: () {},
        ),
        ],
      ),
    );
  }
}

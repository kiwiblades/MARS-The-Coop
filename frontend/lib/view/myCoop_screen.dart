import 'package:flutter/material.dart';
import 'package:frontend/controller/myCoop_controller.dart';
import 'package:frontend/model/myCoop_model.dart';
import 'package:frontend/model/pigeon.dart';
import 'package:frontend/model/profile_model.dart';

class MyCoopScreen extends StatefulWidget {
  static const String routeName = '/myCoopScreen';
  const MyCoopScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return MyCoopScreenState();
  }
}

class MyCoopScreenState extends State<MyCoopScreen> {
  late MyCoopModel model; //model
  late MyCoopController controller; //controller

  @override
  void initState() {
    super.initState();
    model = MyCoopModel();
    // controller = MyCoopController(this);
    //TODO: fetch the user's journals
  }

  void callSetState(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFD1A681),
        image: DecorationImage(
          image: AssetImage('images/woodGrainTexture.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: bodyView(),
      ),
    );
  }

  Widget bodyView() {
    return GridView.builder(
      padding: const EdgeInsets.all(20.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 wide grid
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: model.journalList!.length + 1,
      itemBuilder: itemBuilder,
    );
  }

  Widget itemBuilder(BuildContext context, int index) {
    // LAST TILE → Add button
    if (index == model.journalList!.length) {
      return buildAddTile();
    }

    final journal = model.journalList![index];
    final user = journal.subject;

    return buildPigeonTile(user, index);
  }

  String getBackgroundImage(int index) {
    int column = index % 3;

    if (column == 0) {
      return 'images/leftSideCoopBG.png';
    } else if (column == 1) {
      return 'images/middleCoopBG.png';
    } else {
      return 'images/rightSideCoopBG.png';
    }
  }

  Widget buildPigeonTile(User user, int index) {
    final pigeon = Pigeon.getById(user.pigeonId);
    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background (coop perspective)
              Image.asset(getBackgroundImage(index), fit: BoxFit.cover),

              // Pigeon
              Image.asset(pigeon!.coop, fit: BoxFit.contain),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // Username
        Text(
          user.username,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget buildAddTile() {
  return GestureDetector(
    onTap: () {
    },
    child: Column(
      children: [
        Expanded(
          child: Image.asset(
            'images/addPigeon.png', // your special tile image
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Add',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
}

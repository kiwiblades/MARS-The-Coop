import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
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
  late final MyCoopController controller; //controller
  late MyCoopModel model; //model

  @override
  void initState() {
    super.initState();
    model = MyCoopModel();
    controller = MyCoopController(this);
    //fetch the user's journals
    model.journalList = [];
    //fetch friends
    model.friendList = [];
    controller.loadJournalSubjects();
    controller.loadEligibleFriends();
  }

  void callSetState(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        //wood grain texture bg
        color: Color(0xFFD1A681),
        image: DecorationImage(
          image: AssetImage('images/woodGrainTexture.webp'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(backgroundColor: Colors.transparent, body: bodyView()),
    );
  }

  Widget bodyView() {
    return GridView.builder(
      //grid format for birds
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
    // final tile is the add "button"
    if (index == model.journalList!.length) {
      return buildAddTile();
    }

    final journal = model.journalList![index];
    final user = journal.subject;

    return buildPigeonTile(user, index); //build tile based on subject and index
  }

  //helper function for the background of coop box (the perspective lines)
  String getBackgroundImage(int index) {
    int column = index % 3;

    if (column == 0) {
      return 'images/leftSideCoopBG.webp';
    } else if (column == 1) {
      return 'images/middleCoopBG.webp';
    } else {
      return 'images/rightSideCoopBG.webp';
    }
  }

  //function to build bird tile
  Widget buildPigeonTile(User user, int index) {
    final journal = model.journalList![index];
    final pigeon = Pigeon.getById(
      user.pigeonId,
    ); //get the subject's corresponding pigeon
    return GestureDetector(
      onTap: () => controller.onTapPigeon(context, journal),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(getBackgroundImage(index), fit: BoxFit.cover), //bg
                Image.asset(pigeon!.coop, fit: BoxFit.contain), //pigeon
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            //Username
            user.username,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 16.0,
              color: AppColors.darkBrown,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  //function to build the add tile
  Widget buildAddTile() {
    return GestureDetector(
      onTap: controller.onTapAddNew,
      child: Column(
        children: [
          Expanded(
            child: Image.asset(
              'images/addPigeon.webp', // your special tile image
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: AppColors.darkBrown),
              Text(
                'new',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 16.0,
                  color: AppColors.darkBrown,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//Add pigeon Popup
class FriendSelectionDialog extends StatefulWidget {
  final List<User> friends;

  const FriendSelectionDialog({required this.friends});

  @override
  State<FriendSelectionDialog> createState() => FriendSelectionDialogState();
}

class FriendSelectionDialogState extends State<FriendSelectionDialog> {
  int? selectedIndex; //to keep track of which user is selected for visuals

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.background,
      title: Text(
        'Add New Pigeon to Your Coop',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontSize: 18.0,
          color: AppColors.darkBrown,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 350,
        child: ListView.builder(
          itemCount: widget.friends.length,
          itemBuilder: (context, index) {
            final user = widget.friends[index];
            final isSelected = selectedIndex == index;

            return GestureDetector(
              onTap: () {
                //update selection on tap
                setState(() {
                  selectedIndex = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  //shade if it's selected
                  color: isSelected ? Color(0xFFC0936D) : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? Color(0xFFC0936D) : Colors.transparent,
                    width: isSelected ? 3 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Username of friend
                    Text(
                      user.username,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 14.0,
                        color: AppColors.darkBrown,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          //cancel button
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 14.0,
              color: AppColors.darkBrown,
            ),
          ),
        ),
        ElevatedButton(
          //Add button
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFC0936D)),
          onPressed: selectedIndex == null
              ? null
              : () {
                  Navigator.pop(context, widget.friends[selectedIndex!]);
                },
          child: Text(
            'Add',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 14.0,
              color: AppColors.darkBrown,
            ),
          ),
        ),
      ],
    );
  }
}

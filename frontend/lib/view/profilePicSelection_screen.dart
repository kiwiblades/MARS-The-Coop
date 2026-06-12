import 'package:flutter/material.dart';
import '../controller/profilepicselection_controller.dart';
import '../model/profilePicSelection_model.dart';
import '../services/api_client.dart';
import '../services/user_service.dart';

class ProfilePicSelectionScreen extends StatefulWidget {
  static const String routeName = '/profilePicSelectionScreen';
  const ProfilePicSelectionScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return ProfilePicSelectionScreenState();
  }
}

class ProfilePicSelectionScreenState extends State<ProfilePicSelectionScreen> {
  late final ProfilePicSelectionController controller;
  late final ProfilePicSelectionModel model;
  late final UserService users;

  @override
  void initState() {
    super.initState();
    model = ProfilePicSelectionModel();
    final api = ApiClient();
    users = UserService(api: api);

    controller = ProfilePicSelectionController(this, users: users);
  }

  void callSetState(VoidCallback fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFD1A681),
        image: DecorationImage(
          image: AssetImage('images/woodGrainTexture.webp'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Color(0xFFD1A681),
          title: const Text('Pick Your Pigeon')
        ),
        body: bodyView(),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.onPressedSave,
                child: const Text('Save'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget bodyView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 3 wide grid
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: model.pigeonList!.length,
      itemBuilder: (context, index) {
        final pigeon = model.pigeonList![index];

        final isSelected = model.selectedPigeonIndex == index;
        // final isSelected = state.currentUser!.pigeonId

        return GestureDetector(
          onTap: () => controller.onTapPigeon(index),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFFC0936D) : Colors.transparent,
              border: Border.all(
                color: isSelected ? Color(0xFFC0936D) : Colors.transparent,
                width: isSelected ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      pigeon.side, // using profile image
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    pigeon.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

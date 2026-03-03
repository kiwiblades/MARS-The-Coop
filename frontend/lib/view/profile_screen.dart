import 'package:flutter/material.dart';
import 'package:frontend/controller/profile_controller.dart';
import 'package:frontend/model/pigeon.dart';
import 'package:frontend/model/profile_model.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profileScreen';
  const ProfileScreen({super.key}); 

  @override
  State<StatefulWidget> createState() {
    return ProfileScreenState();
  }
}

class ProfileScreenState extends State<ProfileScreen> {
  late ProfileController controller;
  late ProfileModel model;
  late final UserService users;

  User? currentUser;
  bool isLoading = true;
  String? loadError;
  final GlobalKey<FormState> formKeyUsername = GlobalKey<FormState>();
  final GlobalKey<FormState> formKeyEmail = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    model = ProfileModel();

    final api = ApiClient();
    users = UserService(api: api);

    controller = ProfileController(this, users: users); //link controller
    controller.loadUser(); // fetch /user
  }

  void callSetState(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    final pigeonId = currentUser?.pigeonId ?? 0;
    final pigeon = Pigeon.getById(pigeonId);
    final profileImagePath = pigeon?.profile ?? 'images/pigeonProfile/defaultPigeonProfile.png';

    return Container(
      decoration: const BoxDecoration( //background wood text
        image: DecorationImage(
          image: AssetImage('images/woodGrainTexture.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, //make sure wood texture can be seen
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 270,
                child: Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      //sky background for profile "bar"
                      height: 180,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('images/skyProfileBG.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                
                    Positioned(
                      top: 90,
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Profile image with border
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Color(0xFFCBFCFC), //blue background of pfp
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 5), //white outline for pfp
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  profileImagePath,
                                  //pigeon?.profile?? //default (i need to draw the default really quick) //TODO
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                
                            // Edit button
                            Positioned(
                              bottom: 5,
                              right: 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFC0936D),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Color(0xFF93633A), width: 3),
                                ),
                                child: IconButton( //pfp edit button
                                  icon: const Icon(Icons.edit, color: Color(0xFF93633A)),
                                  onPressed: controller.onPressedProfilePicEdit,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 25), //spacer
              
              Text( //username "title"
                //Profile 'label' meaning the users username
                currentUser?.username ?? '<Username>',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              
              Padding(
                //All text
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Email", //label
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                    Form(
                      key: formKeyEmail,
                      child: Row(
                        children: model.isEditingEmail ? [ //conditionally render based on if the email is being edited or not
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                              initialValue: currentUser?.email ?? '',
                              validator: controller.emailValidator,
                              onSaved: controller.onSaveEmail,
                            ),
                          ),
                          const SizedBox(width: 5),
                          IconButton( //edit email save
                            onPressed: controller.onPressedEditEmailSave,
                            icon: const Icon(Icons.check),
                          ),
                          IconButton( //edit email cancel
                            onPressed: controller.onPressedEditEmailCancel,
                            icon: const Icon(Icons.close),
                          ),
                        ] 
                        :
                        [
                        Text( //email
                            currentUser?.email ?? '<Email>',
                            style: TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 5),
                          IconButton( //email edit button
                            onPressed: controller.onPressedEditEmail,
                            icon: const Icon(Icons.edit),
                          ),
                        ] ,
                      ),
                    ),
                    const SizedBox(height: 5), //spacer
                    const Text(
                      "Username", //label
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 5), //spacer
                    Form(
                      key: formKeyUsername,
                      child: Row(
                        children: model.isEditingUsername ? 
                        [
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Username',
                                border: OutlineInputBorder(),
                              ),
                              initialValue: currentUser?.username ?? '',
                              validator: controller.usernameValidator,
                              onSaved: controller.onSaveUsername,
                            ),
                          ),
                          const SizedBox(width: 5),
                          IconButton( //email edit save
                            onPressed: controller.onPressedEditUsernameSave,
                            icon: const Icon(Icons.check),
                          ),
                          IconButton( //email cancel
                            onPressed: controller.onPressedEditUsernameCancel,
                            icon: const Icon(Icons.close),
                          ),
                        ]
                        :
                        [
                          Text( //username
                            currentUser?.username ?? '<Username>',
                            style: TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 5),
                          IconButton( //username edit button
                            onPressed: controller.onPressedEditUsername,
                            icon: const Icon(Icons.edit),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5), //spacer
                    const Text(
                      "Password", //label
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 10), //spacer
                    InkWell(
                      onTap: controller.onPressedPasswordReset,
                      child: Row(
                        children: [
                          Text(
                            'Reset Password',
                            style: TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right, size: 30),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.0),
                    const Text(
                      'Questions about the app? Contact thecoopmobileapp@gmail.com',
                    ),
                    Row(
                      children: [
                        Text('or checkout this '),
                        TextButton( //info button 
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: controller.onPressedInfo,
                          child: Text(
                            'info',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 7.0),
                    ElevatedButton( //reset password button
                      onPressed: controller.onPressedSignOutButton,
                      child: Text('Sign Out'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

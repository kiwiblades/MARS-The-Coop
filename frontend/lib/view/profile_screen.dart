import 'package:flutter/material.dart';
import 'package:frontend/controller/profile_controller.dart';
import 'package:frontend/model/pigeon.dart';
import 'package:frontend/model/profile_model.dart';

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
  // final User user; //this holds the users information TODO
  // const ProfileScreen(this.user, {super.key}); //TODO idk if this is needed
  // var pigeon = Pigeon.getById(user.pigeonId); //TODO: this should get the associated pigeon from the pigeon list, var is bad practice but idk if "final" will work in this case
  // bool isEditingUsername = false;
  // bool isEditingEmail= false;
  final GlobalKey<FormState> formKeyUsername = GlobalKey<FormState>();
  final GlobalKey<FormState> formKeyEmail = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controller = ProfileController(this); //link controller
    model = ProfileModel();
    //TODO: I believe this is where you could load stuff? idk like user info i.e. controller.loadUser();
  }

  void callSetState(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
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
                                  'images/pigeonProfile/defaultPigeonProfile.png', //TODO this will be the users profile pic for their selected pigeon
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
              
              const Text( //username "title"
                //Profile 'label' meaning the users username
                "Username", //TODO: should be the person's username
                //user.username,
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
                          // Text( //email
                          //   '<Email>', //TODO: this should be the actual email from database
                          //   //user.email ?? 'No email',
                          //   style: TextStyle(fontSize: 20),
                          // ),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                              // initialValue: user.email, //TODO: this should be the email from the DB once it is fetched
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
                            '<Email>', //TODO: this should be the actual email from database
                            //user.email ?? 'No email',
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
                          // Text( //username
                          //   '<Username>', //TODO: this should be the actual email from database
                          //   //user.username,
                          //   style: TextStyle(fontSize: 20),
                          // ),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Username',
                                border: OutlineInputBorder(),
                              ),
                              // initialValue: user.username, //TODO: this should be the username from the DB once it is fetched
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
                            '<Username>', //TODO: this should be the actual email from database
                            //user.username,
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
                    ElevatedButton( //reset password button
                      onPressed: controller.onPressedPasswordReset,
                      child: Text('Reset Password'),
                    ),
                    const SizedBox(height: 10.0), //spacer
                    const Text(
                      'Questions about the app? Contact the coopmobileapp@gmail.com',
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

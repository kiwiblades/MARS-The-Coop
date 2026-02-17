import 'package:flutter/material.dart';
import 'package:frontend/view/profilePicSelection_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profileScreen';
  const ProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return ProfileScreenState();
  }
}

class ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 5),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'images/nicobarPigeon.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
              
                          // Edit button
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 5),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.edit, color: Colors.black),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    ProfilePicSelectionScreen.routeName,
                                  );
                                },
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

            const SizedBox(height: 25),

            const Text(
              //Profile 'label' meaning the users username
              "Username", //should be the person's username
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
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.edit),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '<Email>', //this should be the actual email from database
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5), //spacer
                  const Text(
                    "Username", //label
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 5), //spacer
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.edit),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '<Username>', //this should be the actual email from database
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5), //spacer
                  const Text(
                    "Password", //label
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Reset Password'),
                  ),
                  const SizedBox(height: 10.0), //spacer
                  const Text(
                    'Questions about the app? Contact thecoopmobileapp@gmail.com',
                  ),
                  Row(
                    children: [
                      Text('or checkout this '),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {},
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
    );
  }
}

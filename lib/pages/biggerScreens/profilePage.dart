import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recipe/pages/biggerScreens/loginPage.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  Future<Map<String, String?>> _getUserDataFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? username = prefs.getString('name');
    return {'email': email, 'username': username};
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      /*  appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 10),
          child: IconButton(
            icon: const Icon(
              FontAwesomeIcons.arrowLeft,
              color: Colors.white,
              size: 40,
            ),
            onPressed: () {
              Navigator.pop(context); // Navigate back when pressed
            },
          ),
        ),
        /* actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white, size: 40),
            onPressed: () async {
              // Sign out the user
              await GoogleSignIn().signOut();
              await FirebaseAuth.instance.signOut();
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool("isLoggedIn", false);

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ], */
      ), */
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/test.jpg', // Replace with your image URL
              fit: BoxFit.cover,
            ),
          ),
          // Background color

          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: MediaQuery.of(context).size.height * 0.2),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white60,
                  borderRadius:
                      BorderRadius.circular(20), // Adjust the radius as needed
                ),
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Picture
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: NetworkImage(user?.photoURL ??
                          'https://cdn-icons-png.flaticon.com/512/6717/6717652.png'),
                      backgroundColor: Colors.transparent,
                    ),
                    const SizedBox(height: 20),

                    // User Name
                    Text(
                      user?.displayName ?? 'No Name',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const Text(
                      "Profile",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 30),

                    // Name Field
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.2),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: user?.displayName ?? '33 Name',
                          prefixIcon: const Icon(Icons.person),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Email Field
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.2),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: user?.email ?? '140 Ne',
                          prefixIcon: const Icon(Icons.email),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Phone Number Field
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.2),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: user?.phoneNumber ?? 'Phone',
                          prefixIcon: const Icon(Icons.phone),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Logout Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade400, // Blue color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: const Size(100, 50),
                          ),
                          child: const Icon(
                            Icons.home, size: 30, color: Colors.white,
                            // style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 30),
                        ElevatedButton(
                          onPressed: () async {
                            bool confirmLogout = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Confirm Logout"),
                                      content: const Text(
                                          "Are you sure you want to logout?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(false); // Cancel
                                          },
                                          child: const Text("No"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(true); // Confirm
                                          },
                                          child: const Text("Yes"),
                                        ),
                                      ],
                                    );
                                  },
                                ) ??
                                false;

                            if (confirmLogout) {
                              // Logout logic
                              await GoogleSignIn().signOut();
                              await FirebaseAuth.instance.signOut();
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool("isLoggedIn", false);

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()),
                                (Route<dynamic> route) => false,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.lightBlue.shade400, // Blue color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: const Size(100, 50),
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/logout.svg',
                            color: Colors
                                .white, // Make sure to use your correct asset path
                            // Adjust the size as needed
                            width: 35.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/* import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  // Dummy data for the profile
  final String userName = "John Doe";
  final String email = "johndoe@example.com";
  final String profilePicUrl = "https://cdn-icons-png.flaticon.com/512/6717/6717652.png"; // Replace with your profile image URL

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F4F9),
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Color(0xFF5D4B8E), // Purple background
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Profile Picture on Top
            CircleAvatar(
              radius: 70,
              backgroundImage: NetworkImage(profilePicUrl),
              backgroundColor: Colors.transparent,
            ),
            SizedBox(height: 20),

            // User Information in a List
            Expanded(
              child: ListView(
                children: <Widget>[
                  _buildListTile("Username", userName, Icons.person),
                  _buildListTile("Email", email, Icons.email),
                  _buildListTile(
                    "Change Password",
                    "Update your password",
                    Icons.lock,
                    onTap: () {
                     /*  Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                      ); */
                    },
                  ),
                  _buildListTile(
                    "Deactivate Account",
                    "Temporarily deactivate your account",
                    Icons.remove_circle_outline,
                    onTap: () {
                    /*   Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DeactivateAccountPage()),
                      ); */
                    },
                  ),
                  _buildListTile(
                    "Delete Account",
                    "Permanently delete your account",
                    Icons.delete,
                    onTap: () {
                     /*  Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DeleteAccountPage()),
                      ); */
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Log Out Button
            ElevatedButton(
              onPressed: () {
                // Add your log-out functionality here
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Log Out"),
                    content: Text("Are you sure you want to log out?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                        },
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          // Log out logic goes here
                          // For example: Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text("Log Out"),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5D4B8E), // Purple color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
              child: Text(
                "Log Out",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to create the ListTile widgets
  Widget _buildListTile(String title, String subtitle, IconData icon, {VoidCallback? onTap}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF5D4B8E)),
        title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        onTap: onTap,
      ),
    );
  }
}
 */
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recipe/pages/loginPage.dart';

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
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              // Sign out the user
              await GoogleSignIn().signOut();
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/test.jpg', // Replace with your image URL
              fit: BoxFit.cover,
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                // Profile picture with rounded corners
                CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage(user?.photoURL ??
                      'https://cdn-icons-png.flaticon.com/512/6717/6717652.png'),
                  backgroundColor: Colors.transparent,
                ),
                const SizedBox(height: 20),

                // User Name
                FutureBuilder<Map<String, String?>>(
                  future: _getUserDataFromPrefs(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const Text('Error loading user data');
                    }

                    final userData = snapshot.data;
                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: const Text(
                          'Name:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(user?.displayName ??
                            userData?['username'] ??
                            'No Name'),
                      ),
                    );
                  },
                ),

                // User Email
                FutureBuilder<Map<String, String?>>(
                  future: _getUserDataFromPrefs(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const Text('Error loading email');
                    }

                    final userData = snapshot.data;
                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: const Text(
                          'Email:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            user?.email ?? userData?['email'] ?? 'No Email'),
                      ),
                    );
                  },
                ),

                // User Phone Number
                Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: const Text(
                      'Phone:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(user?.phoneNumber ?? 'No Phone Number'),
                  ),
                ),

                const SizedBox(height: 20),

                // Log Out Button
                ElevatedButton.icon(
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('Log Out'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50), // full width
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
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
              ],
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
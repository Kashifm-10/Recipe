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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Profile picture with rounded corners
              CircleAvatar(
                radius: 70,
                backgroundImage: NetworkImage(
                    user?.photoURL ?? 'https://cdn-icons-png.flaticon.com/512/6717/6717652.png'),
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
                      subtitle:
                          Text(user?.email ?? userData?['email'] ?? 'No Email'),
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
      ),
    );
  }
}

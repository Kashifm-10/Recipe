import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recipe/pages/loginPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final firebase_auth.User? user =
      firebase_auth.FirebaseAuth.instance.currentUser;
  String? email = '';
  String? username = '';
  String? date = '';
  Future<void> _getUserDataFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email');
      username = prefs.getString('name');
      date = prefs.getString('date');
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserDataFromPrefs();
  }

  String toTitleCase(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word; // Handle empty strings safely
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        title: Text(
          "",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 40),
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
          // Background color or other widgets

          // Container on top left of screen
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: MediaQuery.of(context).size.height * 0.12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(user?.photoURL ??
                      'https://images.deepai.org/art-image/d02f0423812a476e90df7368aafb8062/cookbook-minimalist-logo-b477d8-thumb.jpg'),
                  backgroundColor: Colors.white.withOpacity(0.3),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                // User Name
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 15), // Adjust padding as needed
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5), // White background
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                    boxShadow: const [],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              toTitleCase(user?.displayName ?? username!),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.09,
                                color: Color.fromARGB(255, 10, 10, 9),
                              ),
                            ),
                          ),
                          Text(
                            user?.email ?? email!,
                            style: GoogleFonts.poppins(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.03,
                                color: Colors.grey[500]),
                          ),
                          Text(
                            "Creating from: ${date!}",
                            style: GoogleFonts.poppins(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.03,
                                color: Colors.grey[500]),
                          ),
                        ],
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05),
                      /*  SizedBox(
                        child: Text(
                          user?.phoneNumber ?? 'Phone',
                        ),
                      ), */

                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              final GlobalKey<FormState> _formKey =
                                  GlobalKey<FormState>();
                              final TextEditingController
                                  _currentPasswordController =
                                  TextEditingController();
                              final TextEditingController
                                  _newPasswordController =
                                  TextEditingController();
                              final TextEditingController
                                  _confirmPasswordController =
                                  TextEditingController();
                              final TextEditingController _emailController =
                                  TextEditingController();

                              return Container(
                                child: AlertDialog(
                                  title: Text('Enter New Password',  style: GoogleFonts.poppins()),
                                  content: Form(
                                    key: _formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Current Password Field
                                        TextFormField(
                                          controller:
                                              _currentPasswordController,
                                          obscureText: true,
                                          decoration: InputDecoration(
                                            labelText: 'Current Password',
                                            hintText:
                                                'Enter your current password',
                                            filled: true,
                                            fillColor: Color(0xFFFEE1D5),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            /*  prefixIcon: Icon(Icons.lock,
                                                color: Color(0xFF5C2C2C)), */
                                            labelStyle: GoogleFonts.poppins(
                                              color: Color(0xFF5C2C2C),
                                            ),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.never,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Current password is required';
                                            }
                                            return null;
                                          },
                                        ),
                                        SizedBox(height: 10),

                                        // New Password Field
                                        TextFormField(
                                          controller: _newPasswordController,
                                          obscureText: true,
                                          decoration: InputDecoration(
                                            labelText: 'New Password',
                                            hintText: 'Enter your new password',
                                            filled: true,
                                            fillColor: Color(0xFFFEE1D5),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            /*  prefixIcon: Icon(Icons.lock,
                                                color: Color(0xFF5C2C2C)), */
                                            labelStyle: GoogleFonts.poppins(
                                              color: Color(0xFF5C2C2C),
                                            ),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.never,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Password is required';
                                            }
                                            if (value.length < 8) {
                                              return 'Password must be at least 8 characters';
                                            }
                                            final regex = RegExp(
                                                r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$');
                                            if (!regex.hasMatch(value)) {
                                              return 'Password requires uppercase, lowercase, number, and symbol';
                                            }
                                            return null;
                                          },
                                        ),
                                        SizedBox(height: 10),

                                        // Confirm Password Field
                                        TextFormField(
                                          controller:
                                              _confirmPasswordController,
                                          obscureText: true,
                                          decoration: InputDecoration(
                                            labelText: 'Confirm Password',
                                            hintText:
                                                'Re-enter your new password',
                                            filled: true,
                                            fillColor: Color(0xFFFEE1D5),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            /*  prefixIcon: Icon(Icons.lock,
                                                color: Color(0xFF5C2C2C)), */
                                            labelStyle: GoogleFonts.poppins(
                                              color: Color(0xFF5C2C2C),
                                            ),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.never,
                                          ),
                                          validator: (value) {
                                            if (value !=
                                                _newPasswordController.text) {
                                              return 'Passwords do not match';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                      },
                                      child: Text('Cancel',  style: GoogleFonts.poppins()),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          // Validate Current Password with Supabase
                                          final validateResponse =
                                              await Supabase
                                                  .instance.client
                                                  .from('users')
                                                  .select(
                                                      'email, password, name')
                                                  .eq('email',
                                                      email!.toLowerCase())
                                                  .eq(
                                                      'password',
                                                      _currentPasswordController
                                                          .text);

                                          if (validateResponse.isEmpty) {
                                            const snackBar = SnackBar(
                                              /// need to set following properties for best effect of awesome_snackbar_content
                                              elevation: 0,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              backgroundColor:
                                                  Colors.transparent,
                                              content: AwesomeSnackbarContent(
                                                color: Colors.red,
                                                title: 'Oh Snap!',
                                                message:
                                                    'Invalid current password',

                                                /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                                                contentType:
                                                    ContentType.failure,
                                                inMaterialBanner: true,
                                              ),
                                            );

                                            return;
                                          }

                                          // Update Password in Supabase
                                          final updateResponse = await Supabase
                                              .instance.client
                                              .from('users')
                                              .update({
                                            'password':
                                                _newPasswordController.text
                                          }).eq('email', email!.toLowerCase());

                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                          const snackBar = SnackBar(
                                            /// need to set following properties for best effect of awesome_snackbar_content
                                            elevation: 0,
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: Colors.transparent,
                                            content: AwesomeSnackbarContent(
                                              color: Colors.red,
                                              title: 'Yay!',
                                              message:
                                                  'Password changed successfully!',

                                              /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                                              contentType: ContentType.failure,
                                              inMaterialBanner: true,
                                            ),
                                          );
                                          ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
                                        }
                                      },
                                      child: Text('Confirm',  style: GoogleFonts.poppins()),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 241, 128, 181)
                                  .withOpacity(0.3), // Blue color
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          shadowColor: Colors.transparent,
                          minimumSize: const Size(100, 40),
                        ),
                        child: Text(
                          'Change Password',
                          style: GoogleFonts.poppins(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.035,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
/*                       SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
 */
                      ElevatedButton(
                        onPressed: () async {
                          bool confirmLogout = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Confirm Logout"),
                                    content:  Text(
                                        "Are you sure you want to logout?",  style: GoogleFonts.poppins()),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(false); // Cancel
                                        },
                                        child:  Text("No",  style: GoogleFonts.poppins()),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(true); // Confirm
                                        },
                                        child:  Text("Yes",  style: GoogleFonts.poppins()),
                                      ),
                                    ],
                                  );
                                },
                              ) ??
                              false;

                          if (confirmLogout) {
                            // Logout logic
                            await GoogleSignIn().signOut();
                            await firebase_auth.FirebaseAuth.instance.signOut();
                            final prefs = await SharedPreferences.getInstance();
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
                              const Color.fromARGB(255, 241, 128, 181)
                                  .withOpacity(0.3), // Blue color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(100, 40),
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          "Logout",
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.035,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                    ],
                  ),
                ),

                // Logout Button
                Row(
                  children: [
                    const SizedBox(width: 30),
                  ],
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
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
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
        title: Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
        onTap: onTap,
      ),
    );
  }
}
 */

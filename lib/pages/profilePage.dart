import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gif/gif.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recipe/pages/loginPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_popup/flutter_popup.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late GifController _controller;

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
      date = prefs.getString('date') ?? ' ';
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = GifController(vsync: this);

    _getUserDataFromPrefs();
  }

  String toTitleCase(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word; // Handle empty strings safely
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  void showSwipeableImageDialog(BuildContext context) {
    final PageController _pageController = PageController();
    int _currentPage = 0;

    // Define the instructions for each page
    final List<String> instructions = [
      'How to Add Dishes',
      'How to Update Dishes',
      'Step 3: Start exploring the app features and track your progress.',
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              contentPadding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width *
                      0.02), // Remove padding
              content: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height *
                    0.7, // Adjust dialog size
                child: Column(
                  children: [
                    // Instructions text at the top (dynamic per page)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        instructions[
                            _currentPage], // Display instruction for current page
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    // PageView for horizontally swiping images
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage =
                                index; // Update the current page index
                          });
                        },
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                                20.0), // Adjust the radius as needed
                            child: Gif(
                              height: 1,
                              image: const AssetImage("assets/images/dish.gif"),
                              fit: BoxFit.fill,
                              //controller: _controller, // if duration and fps is null, original gif fps will be used.
                              //fps: 30,
                              //duration: const Duration(seconds: 3),
                              autostart: Autostart.loop,
                              //placeholder: (context) => const Text('Loading...'),
                              /*   onFetchCompleted: () {
                                   _controller.reset();
                                   _controller.forward();
                                 }, */
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  20.0), // Adjust the radius as needed
                              child: Gif(
                                height: 1,
                                image: const AssetImage(
                                    "assets/images/update.jpg"),
                                fit: BoxFit.fill,
                                //controller: _controller, // if duration and fps is null, original gif fps will be used.
                                //fps: 30,
                                //duration: const Duration(seconds: 3),
                                autostart: Autostart.loop,
                                //placeholder: (context) => const Text('Loading...'),
                                /*   onFetchCompleted: () {
                                     _controller.reset();
                                     _controller.forward();
                                   }, */
                              ),
                            ),
                          ),
                          /* _SwipeableImagePage(
                            imageUrl: 'assets/images/update.jpg',
                          ), */
                          _SwipeableImagePage(
                            imageUrl: 'assets/images/logo.jpg',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),

                    // Dots to indicate the current page
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3, // Number of pages
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: _currentPage == index ? 12.0 : 8.0,
                            height: 8.0,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? Colors.blue
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
          style: GoogleFonts.hammersmithOne(
              fontWeight: FontWeight.bold, fontSize: 40),
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
                              style: GoogleFonts.hammersmithOne(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.09,
                                color: const Color.fromARGB(255, 10, 10, 9),
                              ),
                            ),
                          ),
                          Text(
                            user?.email ?? email!,
                            style: GoogleFonts.hammersmithOne(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.03,
                                color: Colors.grey[500]),
                          ),
                          Text(
                            "Creating from: ${date!}",
                            style: GoogleFonts.hammersmithOne(
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
                      /* CustomPopup(
                        arrowColor: Colors.white,
                        barrierColor: Colors.transparent,
                        backgroundColor: Colors.white,
                        content: ElevatedButton(
                          onPressed: () {
                            showSwipeableImageDialog(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white
                              /*   const Color.fromARGB(255, 241, 128, 181)
                                    .withOpacity(0.5) */, // Blue color
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            shadowColor: Colors.transparent,
                            minimumSize: const Size(100, 40),
                          ),
                          child: Text(
                            'How to add/update/delete dish',
                            style: GoogleFonts.hammersmithOne(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.035,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 241, 128, 181)
                                .withOpacity(0.3), // Background color
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.transparent, // No shadow
                              ),
                            ],
                          ),
                          child: Text(
                            'Help',
                            style: GoogleFonts.hammersmithOne(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.035,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                                  title: Text('Enter New Password',
                                      style: GoogleFonts.hammersmithOne()),
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
                                            fillColor: const Color(0xFFFEE1D5),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            /*  prefixIcon: Icon(Icons.lock,
                                                color: Color(0xFF5C2C2C)), */
                                            labelStyle:
                                                GoogleFonts.hammersmithOne(
                                              color: const Color(0xFF5C2C2C),
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
                                        const SizedBox(height: 10),

                                        // New Password Field
                                        TextFormField(
                                          controller: _newPasswordController,
                                          obscureText: true,
                                          decoration: InputDecoration(
                                            labelText: 'New Password',
                                            hintText: 'Enter your new password',
                                            filled: true,
                                            fillColor: const Color(0xFFFEE1D5),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            /*  prefixIcon: Icon(Icons.lock,
                                                color: Color(0xFF5C2C2C)), */
                                            labelStyle:
                                                GoogleFonts.hammersmithOne(
                                              color: const Color(0xFF5C2C2C),
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
                                        const SizedBox(height: 10),

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
                                            fillColor: const Color(0xFFFEE1D5),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            /*  prefixIcon: Icon(Icons.lock,
                                                color: Color(0xFF5C2C2C)), */
                                            labelStyle:
                                                GoogleFonts.hammersmithOne(
                                              color: const Color(0xFF5C2C2C),
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
                                      child: Text('Cancel',
                                          style: GoogleFonts.hammersmithOne()),
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
                                      child: Text('Confirm',
                                          style: GoogleFonts.hammersmithOne()),
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
                          style: GoogleFonts.hammersmithOne(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.035,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      /* SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01), */

                      ElevatedButton(
                        onPressed: () async {
                          bool confirmLogout = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Confirm Logout"),
                                    content: Text(
                                        "Are you sure you want to logout?",
                                        style: GoogleFonts.hammersmithOne()),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(false); // Cancel
                                        },
                                        child: Text("No",
                                            style:
                                                GoogleFonts.hammersmithOne()),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(true); // Confirm
                                        },
                                        child: Text("Yes",
                                            style:
                                                GoogleFonts.hammersmithOne()),
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
                          style: GoogleFonts.hammersmithOne(
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
                const Row(
                  children: [
                    SizedBox(width: 30),
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
                style: GoogleFonts.hammersmithOne(fontSize: 16, fontWeight: FontWeight.bold),
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
        title: Text(title, style: GoogleFonts.hammersmithOne(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: GoogleFonts.hammersmithOne(fontSize: 14, color: Colors.grey[600])),
        onTap: onTap,
      ),
    );
  }
}
 */

class _SwipeableImagePage extends StatelessWidget {
  final String imageUrl;

  _SwipeableImagePage({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ],
    );
  }
}

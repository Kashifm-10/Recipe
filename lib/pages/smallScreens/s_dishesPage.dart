import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frino_icons/frino_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:recipe/collections/dishes.dart';
import 'package:recipe/models/br_database.dart';
import 'package:recipe/models/isar_instance.dart';
import 'package:recipe/pages/biggerScreens/recipePage.dart';
import 'package:recipe/list_view/dish_tile.dart';
import 'package:recipe/pages/biggerScreens/home.dart';
import 'package:animated_switch/animated_switch.dart';
import 'package:recipe/pages/smallScreens/s_recipePage.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async'; // For using Timer
import 'package:drop_down_list/drop_down_list.dart';
import 'package:http/http.dart' as http;

class smalldishesList extends StatefulWidget {
  smalldishesList({super.key, required this.type, required this.title});
  String? type;
  String? title;

  State<smalldishesList> createState() => _smalldishesListState();
}

class _smalldishesListState extends State<smalldishesList> {
  //text controller to access what the user typed
  TextEditingController textController = TextEditingController();
  final isar = IsarInstance().isar;
  List<Dish> _filteredNotes = [];
  List<Dish> _sortededNotes = [];
  List<Title> currentTitles = [];
  late SharedPreferences prefs;
  bool positive = false;

  bool ai = false;
  File? _image;
  final picker = ImagePicker();
  String? _uploadedImageUrl = ' ';
  String? _publicId;
  Uint8List? _imageBytes;
  TextEditingController _promptController = TextEditingController();

  String dropdownValue = 'A-Z'; // Class-level variable
  int? serial = 0;
  List<bool> _isSelected = [true, false, false]; // Default to filter by all
  int _currentIndex = 0;
  String? dishName;
  TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  bool _isSearchVisible = false;
  final FocusNode _focusNode = FocusNode();

  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isLoading = true; // Manage loading state
  final List<SelectedListItem> _sortingOptions = [
    SelectedListItem(name: 'A-Z', value: 'A-Z'),
    SelectedListItem(name: 'Z-A', value: 'Z-A'),
    SelectedListItem(name: 'Shortest', value: 'Shortest'),
    SelectedListItem(name: 'Longest', value: 'Longest'),
    SelectedListItem(name: 'Newest', value: 'Newest'),
    SelectedListItem(name: 'Oldest', value: 'Oldest'),
  ];
  List<Color> colorList = [
    Colors.orange.shade400,
    Colors.green.shade400,
    Colors.red.shade400,
    Colors.brown.shade500,
    Colors.red.shade200,
    Colors.deepOrange.shade500,
    Colors.yellow.shade900,
    Colors.blue.shade300,
    Colors.green.shade700,
    Colors.deepPurple.shade300,
  ];

  void _onSortChanged(List<dynamic> selectedList) {
    if (selectedList.isNotEmpty) {
      final String selectedValue =
          selectedList[0].name; // Get the name of the selected item
      setState(() {
        dropdownValue = selectedValue;
      });
      _filterAndSortNotes(); // Apply filter and sort
    }
  }

  final Random _random = Random();
  final List<String> _lottieFiles = [
    'assets/lottie_json/cat.json',
    'assets/lottie_json/ghost.json',
    'assets/lottie_json/fall.json',
    'assets/lottie_json/cups.json'
  ];
  late final String selectedLottie;

  @override
  void initState() {
    super.initState();
    selectedLottie = _lottieFiles[_random.nextInt(_lottieFiles.length)];
    _createTutorial();
    Timer(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
    readDishes(widget.type!);
    _speech = stt.SpeechToText();
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        print("Listening started..."); // Debugging statement
        _speech.listen(
          onResult: (result) {
            print(
                "Result received: ${result.recognizedWords}"); // Debugging statement
            setState(() {
              searchQuery = result.recognizedWords.toLowerCase();
              _searchController.text = searchQuery; // Update TextField
              _filterAndSortNotes(); // Filter notes based on voice input
            });
          },
        );

        await Future.delayed(const Duration(seconds: 5)); // Minimum wait time
        await _speech.stop(); // Stop the speech recognition
        setState(() => _isListening = false); // Update state
        print("Listening stopped..."); // Debugging statement
      } else {
        print("Speech recognition is not available.");
      }
    }
  }

  void _stopListening() async {
    if (_isListening) {
      await _speech.stop(); // Stop the speech recognition
      setState(() => _isListening = false); // Update state
      print("Listening stopped..."); // Debugging statement
    }
  }

  final SupabaseClient supabase = Supabase.instance.client;

  // Load serial from Supabase
  Future<void> loadSerial() async {
    final response = await supabase
        .from('serial') // Replace with your table name
        .select(
            'serial') // Replace with the column name where the serial is stored
        .single();

    setState(() {
      serial = response['serial'] ?? 0;
    });
    // print(serial);
  }

  // Save serial to Supabase
  Future<void> saveSerial(int num) async {
    // Assume `id` is the unique identifier for the row you want to update
    final response = await supabase
        .from('serial')
        .update({'serial': num}) // Update the serial column
        .eq('id',
            1); // Specify the unique identifier (replace '1' with the actual row id)
  }

  //function to create a note
  void createDish() {
    const red = Color(0xFFFD0821);
    const green = Color(0xFF46E82E);
    const borderWidth = 10.0;
    const height = 58.0;
    const innerIndicatorSize = height - 4 * borderWidth;
    String? selectedOption;
    double selectedDurationHours = 0.5; // Start with 1 hour
    bool isSwitched = false;
    String category = '0';
    String? duration;
    textController.clear();
    bool isTextFieldEmpty = false; // Flag for empty text field error message

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0), // Rounded corners
            ),
            backgroundColor: Colors.white,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "New Dish",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 0.0),
                  child: SizedBox(
                    width: 70,
                    height: 35,
                    child: CustomAnimatedToggleSwitch(
                      current: category == '0' ? false : true,
                      spacing: 36.0,
                      values: const [false, true],
                      animationDuration: const Duration(milliseconds: 350),
                      animationCurve: Curves.bounceOut,
                      iconBuilder: (context, local, global) => const SizedBox(),
                      onTap: (_) => setState(
                          () => category = category == '0' ? '1' : '0'),
                      iconsTappable: false,
                      onChanged: (b) =>
                          setState(() => category = b ? '1' : '0'),
                      height: 40,
                      padding: const EdgeInsets.all(5.0),
                      indicatorSize: const Size.square(40),
                      foregroundIndicatorBuilder: (context, global) {
                        return Container(
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: Center(
                            child: category == '0'
                                ? const Icon(Icons.eco,
                                    size: 20.0, color: Colors.green)
                                : SvgPicture.asset(
                                    'assets/icons/steak_icon.svg',
                                    width: 20.0,
                                    height: 20.0,
                                    color: Colors.red,
                                  ),
                          ),
                        );
                      },
                      wrapperBuilder: (context, global, child) {
                        final color = Color.lerp(
                            Colors.green, Colors.red, global.position)!;
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(50.0),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.7),
                                blurRadius: 12.0,
                                offset: const Offset(0.0, 8.0),
                              ),
                            ],
                          ),
                          child: child,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            content: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dish Name TextField
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        hintText: 'Dish name',
                        hintStyle: GoogleFonts.poppins(
                            fontSize: 16, color: Colors.grey.shade600),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  // Show error message if text field is empty
                  if (isTextFieldEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        'Please enter a dish name.',
                        style: GoogleFonts.poppins(
                            color: Colors.red.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ),

                  // Slider for Duration Selection
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 400,
                        child: Slider(
                          value: selectedDurationHours,
                          min: 0.5,
                          max: 5,
                          divisions: 9,
                          onChanged: (value) {
                            setState(() {
                              selectedDurationHours = value;
                            });
                          },
                          activeColor: colorList[int.parse(widget.type!) - 1],
                          inactiveColor: Colors.grey.shade300,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Text(
                          () {
                            int hours = selectedDurationHours.toInt();
                            int minutes =
                                ((selectedDurationHours - hours) * 60).toInt();

                            if (hours > 0 && minutes > 0) {
                              return '$hours hr $minutes min';
                            } else if (hours > 0) {
                              return '$hours hr';
                            } else if (minutes > 0) {
                              return '$minutes min';
                            } else {
                              return '0 min';
                            }
                          }(),
                          style: GoogleFonts.poppins(
                              color: Colors.grey.shade700, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Enable AI Image",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.1,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                        width: MediaQuery.of(context).size.width * 0.13,
                        child: CustomAnimatedToggleSwitch<bool>(
                          current: ai,
                          spacing: 36.0,
                          values: const [false, true],
                          animationDuration: const Duration(milliseconds: 350),
                          animationCurve: Curves.ease,
                          iconBuilder: (context, local, global) =>
                              const SizedBox(),
                          onTap: (_) => setState(() => ai = !ai),
                          iconsTappable: false,
                          onChanged: (b) => setState(() => ai = b),
                          height: 40,
                          padding: const EdgeInsets.all(5.0),
                          indicatorSize: Size.square(
                              MediaQuery.of(context).size.width * 0.03),
                          foregroundIndicatorBuilder: (context, global) {
                            return Container(
                              width: MediaQuery.of(context).size.width * 0.01,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                              child: Center(
                                child: ai
                                    ? Icon(Icons.smart_toy,
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.01,
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255))
                                    : Icon(Icons.image,
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.005,
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255)),
                              ),
                            );
                          },
                          wrapperBuilder: (context, global, child) {
                            final color = Color.lerp(
                                Colors.grey, Colors.blue, global.position)!;
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(50.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.7),
                                    blurRadius: 15.0,
                                    offset: const Offset(0.0, 5.0),
                                  ),
                                ],
                              ),
                              child: child,
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  if (!ai)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo, color: Colors.white),
                          label: const Text('Pick from Gallery',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                colorList[int.parse(widget.type!) - 1],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 12.0),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(
                            Icons.camera,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Take a Picture',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                colorList[int.parse(widget.type!) - 1],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 12.0),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                  textStyle: GoogleFonts.poppins(fontSize: 16),
                ),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  showLoadingDialog(context);
                  setState(() {
                    // Check if the text field is empty
                    isTextFieldEmpty = textController.text.isEmpty;
                  });

                  if (!isTextFieldEmpty) {
                    if (!ai) {
                      await _uploadImage(serial.toString());
                    } else {
                      await generateAIImage(serial.toString());
                      await _uploadToCloudinaryFromAI(
                          _imageBytes!, serial.toString());
                    }

                    serial;
                    int incrementedSerial = (serial! + 1);
                    saveSerial(incrementedSerial);

                    final now = DateTime.now();
                    final date =
                        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                    final time =
                        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

                    context.read<database>().addDish(
                        serial.toString(),
                        textController.text,
                        widget.type!,
                        selectedDurationHours.toStringAsFixed(1),
                        category,
                        date,
                        time,
                        _uploadedImageUrl ?? ' ');
                    readDishes(widget.type!);
                    duration = selectedDurationHours.toStringAsFixed(1);
                    _uploadedImageUrl = ' ';
                    ai = false;
                    Navigator.pop(context);
                    Navigator.pop(context);
                    textController.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorList[int.parse(widget.type!) - 1],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 12.0),
                ),
                child: Text(
                  'Create',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  //read notes
  void readDishes(String type) async {
    await context.read<database>().fetchDishes(type);
  }

  void updateDish(Dish name, String type, String dish) async {
    final response = await Supabase.instance.client
        .from('dishes')
        .select('id') // Specify the field to fetch
        .eq('type', type) // First filter
        .eq('name', dish); // Second filter (example)
    final data = List<Map<String, dynamic>>.from(response);
    textController.text = name.name;
    int dishId = data.isNotEmpty ? data[0]['id'] : 0; // Ensure a default value
    String category = name.category!; // Default value
    String serial = name.serial!;
    String url = name.imageUrl ?? ' ';
    String selectedDurationHours = name.duration!; // Default duration
    bool isTextFieldEmpty = false; // Flag for empty text field error message

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  20.0), // Large rounded corners for a smooth look
            ),
            backgroundColor: Colors.white,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "Update Dish",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors
                            .black87, // Dark, professional color for the title
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Show confirmation dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Confirm Deletion"),
                            content: const Text(
                                "Are you sure you want to delete this dish?"),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  await _deleteImage(name.serial!);
                                  deleteNote(name.id, widget.type!, name.name);
                                  Navigator.pop(
                                      context); // Close confirmation dialog
                                  Navigator.pop(context); // Close update dialog
                                },
                                child: const Text("Yes, Delete"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(
                                      context); // Close confirmation dialog
                                },
                                child: const Text("Cancel"),
                              ),
                            ],
                          ),
                        );
                      },
                      icon:
                          const Icon(Icons.delete, color: Colors.red, size: 25),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 0.0),
                  child: SizedBox(
                    width: 70,
                    height: 35,
                    child: CustomAnimatedToggleSwitch(
                      current: category == '0'
                          ? false
                          : true, // false for 'Veg', true for 'Non-Veg'
                      spacing: 36.0,
                      values: const [false, true],
                      animationDuration: const Duration(milliseconds: 350),
                      animationCurve: Curves.bounceOut,
                      iconBuilder: (context, local, global) => const SizedBox(),

                      onTap: (_) => setState(() => category = category == '0'
                          ? '1'
                          : '0'), // Toggle between 'Veg' and 'Non-Veg'
                      iconsTappable: false,
                      onChanged: (b) => setState(
                          () => category = b ? '1' : '0'), // Update category
                      height: 40,
                      padding: const EdgeInsets.all(5.0), // Adjust the padding
                      indicatorSize:
                          const Size.square(40), // Adjust the indicator size
                      foregroundIndicatorBuilder: (context, global) {
                        return Container(
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: category == '0' // 'Veg'
                                ? const Icon(
                                    Icons.eco,
                                    size: 20.0,
                                    color: Colors.green,
                                  )
                                : SvgPicture.asset(
                                    'assets/icons/steak_icon.svg',
                                    width: 20.0,
                                    height: 20.0,
                                    color: Colors.red,
                                  ),
                          ),
                        );
                      },
                      wrapperBuilder: (context, global, child) {
                        final color = Color.lerp(
                            Colors.green, Colors.red, global.position)!;
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(50.0),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.7),
                                blurRadius: 12.0,
                                offset: const Offset(0.0, 8.0),
                              ),
                            ],
                          ),
                          child: child,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            content: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dish Name TextField
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        hintText: 'Dish name',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isTextFieldEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        'Please enter a dish name.',
                        style: GoogleFonts.poppins(
                            color: Colors.red.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ),

                  // Slider for Duration Selection
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 400, // Constrain the slider width
                        child: Slider(
                          value: double.parse(selectedDurationHours),
                          min: 0.5,
                          max: 5,
                          divisions: 9,
                          onChanged: (value) {
                            setState(() {
                              selectedDurationHours = value.toStringAsFixed(1);
                            });
                          },
                          activeColor: colorList[int.parse(widget.type!) - 1],
                          inactiveColor: Colors.grey.shade300,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Text(
                          () {
                            double duration =
                                double.parse(selectedDurationHours);
                            int hours = duration.toInt();
                            int minutes = ((duration - hours) * 60).toInt();

                            if (hours > 0 && minutes > 0) {
                              return '$hours hr $minutes min';
                            } else if (hours > 0) {
                              return '$hours hr';
                            } else if (minutes > 0) {
                              return '$minutes min';
                            } else {
                              return '0 min';
                            }
                          }(),
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Update AI Image",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.1,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                        width: MediaQuery.of(context).size.width * 0.13,
                        child: CustomAnimatedToggleSwitch<bool>(
                          current: ai,
                          spacing: 36.0,
                          values: const [false, true],
                          animationDuration: const Duration(milliseconds: 350),
                          animationCurve: Curves.ease,
                          iconBuilder: (context, local, global) =>
                              const SizedBox(),
                          onTap: (_) => setState(() => ai = !ai),
                          iconsTappable: false,
                          onChanged: (b) => setState(() => ai = b),
                          height: 40,
                          padding: const EdgeInsets.all(5.0),
                          indicatorSize: Size.square(
                              MediaQuery.of(context).size.width * 0.03),
                          foregroundIndicatorBuilder: (context, global) {
                            return Container(
                              width: MediaQuery.of(context).size.width * 0.01,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                              child: Center(
                                child: ai
                                    ? Icon(Icons.smart_toy,
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.01,
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255))
                                    : Icon(Icons.image,
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.005,
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255)),
                              ),
                            );
                          },
                          wrapperBuilder: (context, global, child) {
                            final color = Color.lerp(
                                Colors.grey, Colors.blue, global.position)!;
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(50.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.7),
                                    blurRadius: 15.0,
                                    offset: const Offset(0.0, 5.0),
                                  ),
                                ],
                              ),
                              child: child,
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  if (!ai)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo, color: Colors.white),
                          label: const Text('Pick from Gallery',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                colorList[int.parse(widget.type!) - 1],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 12.0),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(
                            Icons.camera,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Take a Picture',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                colorList[int.parse(widget.type!) - 1],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 12.0),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            actions: [
              // Cancel Button
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                  textStyle: GoogleFonts.poppins(fontSize: 16),
                ),
                child: const Text('Cancel'),
              ),
              // Update Button
              ElevatedButton(
                onPressed: () async {
                  showUpdatingingDialog(context);

                  setState(() {
                    // Check if the text field is empty
                    isTextFieldEmpty = textController.text.isEmpty;
                  });
                  if (textController.text.isNotEmpty) {
                    await isImageUrlValid(serial);
                    final now = DateTime.now();
                    final date =
                        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                    final time =
                        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

                    // Update dish information
                    context.read<database>().updateDish(
                        dishId, // Dish ID to update
                        textController.text,
                        widget.type!,
                        selectedDurationHours,
                        category,
                        date,
                        time,
                        _uploadedImageUrl == ' ' ? url : _uploadedImageUrl!);
                    Navigator.pop(context);
                    _uploadedImageUrl = ' ';
                    textController.clear();
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorList[int.parse(widget.type!) - 1],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 12.0),
                ),
                child: Text(
                  'Update',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  //delete a note
  void deleteNote(int id, String type, String dish) async {
    final response = await Supabase.instance.client
        .from('dishes')
        .select('id, serial') // Specify both fields to fetch (id and serial)
        .eq('type', type) // Filter by type
        .eq('name', dish); // Filter by dish name

    // Convert the response to a list of maps
    final data = List<Map<String, dynamic>>.from(response);

    // Clear the previous data if necessary

    // Extract the id and serial from the response
    int dishId = data.isNotEmpty ? data[0]['id'] : 0;
    String serial = data.isNotEmpty ? data[0]['serial'] : '';

    // Call the deleteDish method with both id and serial (if necessary)
    context.read<database>().deleteDish(dishId, widget.type!, serial);
  }

  void _filterAndSortNotes() {
    final noteDatabase = context.read<database>();

    // Apply filtering
    _filteredNotes = noteDatabase.currentNames.where((note) {
      final matchesSearch =
          note.name.toLowerCase().contains(searchQuery.toLowerCase());

      if (_currentIndex == 0) {
        return matchesSearch; // Show all items that match the search
      } else if (_currentIndex == 1) {
        return note.category == '1' &&
            matchesSearch; // Filter by `category == 1` and search
      } else if (_currentIndex == 2) {
        return note.category == '0' &&
            matchesSearch; // Filter by `category == 0` and search
      }
      return false; // Default case
    }).toList();

    // Apply sorting
    _sortededNotes = List.from(_filteredNotes);

    if (dropdownValue == 'A-Z') {
      _sortededNotes.sort((a, b) => a.name.compareTo(b.name)); // A-Z
    } else if (dropdownValue == 'Z-A') {
      _sortededNotes.sort((a, b) => b.name.compareTo(a.name)); // Z-A
    } else if (dropdownValue == 'Shortest') {
      _sortededNotes
          .sort((a, b) => a.duration!.compareTo(b.duration!)); // Short-Long
    } else if (dropdownValue == 'Longest') {
      _sortededNotes
          .sort((a, b) => b.duration!.compareTo(a.duration!)); // Long-Short
    } else if (dropdownValue == 'Newest') {
      _sortededNotes.sort((a, b) {
        int dateComparison = b.date!.compareTo(a.date!); // New-Old
        if (dateComparison != 0) return dateComparison;
        return b.time!
            .compareTo(a.time!); // If dates are equal, compare by time
      });
    } else if (dropdownValue == 'Oldest') {
      _sortededNotes.sort((a, b) {
        int dateComparison = a.date!.compareTo(b.date!); // Old-New
        if (dateComparison != 0) return dateComparison;
        return a.time!
            .compareTo(b.time!); // If dates are equal, compare by time
      });
    }
  }

  // Default to 'Type 0', adjust as needed
  Widget iconBuilder(int value) {
    return rollingIconBuilder(value, false);
  }

  Widget rollingIconBuilder(int? value, bool foreground) {
    final icon = iconDataByValue(value);

    // Check if we need to display an SVG or IconData
    if (icon is String && icon == 'svg_meat') {
      // Show SVG if icon is a string that indicates SVG
      return SvgPicture.asset(
        'assets/icons/steak_icon.svg', // Path to custom SVG
        width: MediaQuery.of(context).size.width * 0.04,
        height: 25.0,
        color: _currentIndex == value
            ? iconColorBuilder(value!)
            : Colors.grey, // Adjust color
      );
    } else if (icon is String && icon == 'all') {
      // Show SVG if icon is a string that indicates SVG
      return Image.asset(
        'assets/icons/all.png', // Path to custom SVG
        width: MediaQuery.of(context).size.width * 0.04,
        height: 25.0,
        color: _currentIndex == value ? null : Colors.grey, // Adjust color
      );
    } else if (icon is IconData) {
      // Default: Show IconData if it's an IconData instance
      return Icon(
        icon,
        size: MediaQuery.of(context).size.width * 0.04,
        color: _currentIndex == value
            ? iconColorBuilder(value!)
            : Colors.grey, // Adjust color
      );
    } else {
      return Icon(
        Icons.lightbulb_outline_rounded,
        size: MediaQuery.of(context).size.width * 0.06,
        color: Colors.grey, // Default to grey color
      );
    }
  }

  dynamic iconDataByValue(int? value) {
    switch (value) {
      case 0:
/*         return FontAwesomeIcons.bowlRice; // Default FontAwesome icon
 */
        return 'all';
      case 1:
        return 'svg_meat'; // Special case for SVG meat icon
      case 2:
        return Icons.eco; // Default material icon
      default:
        return Icons.lightbulb_outline_rounded; // Default icon if no match
    }
  }

  Widget sizeIconBuilder(BuildContext context,
      AnimatedToggleProperties<int> local, GlobalToggleProperties<int> global) {
    return iconBuilder(local.value);
  }

  Color colorBuilder(int value) => switch (value) {
        0 => Colors.transparent, //const Color.fromARGB(255, 96, 143, 230),
        1 => Colors.transparent,
        2 => Colors.transparent,
        _ => Colors.transparent,
      };

  Color iconColorBuilder(int value) => switch (value) {
        0 => const Color(0xFF795548), // Blue for value 0
        1 => Colors.red, // Red for value 1
        2 => Colors.green, // Green for value 2
        _ => Colors.grey, // Default color if value is not matched
      };

  /*  Widget coloredRollingIconBuilder(int value, bool foreground) {
    final color = foreground ? colorBuilder(value) : null;
    return Icon(
      iconDataByValue(value),
      color: _currentIndex == value
          ? Colors.blue
          : Colors.grey, // Change icon color when selected
      size: 17.0, // Adjust icon size here for colored icons
    );
  }
 */
  int value = 0;

  final GlobalKey _floatingButtonKey = GlobalKey();
  final GlobalKey _categoryButtonKey = GlobalKey();
  final GlobalKey _sortButtonKey = GlobalKey();

  Future<void> _createTutorial() async {
    // Get SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();

    // Check if the tutorial has already been shown
    bool isTutorialShown = prefs.getBool('tutorialShowndishes') ?? false;

    // If it has been shown, return early
    if (isTutorialShown) return;

    // Define the tutorial targets
    final targets = [
      TargetFocus(
        identify: 'floatingButton',
        keyTarget: _floatingButtonKey,
        alignSkip: Alignment.bottomCenter,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => Text(
              'Use this button to add new dishes to the list',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'categoryButton',
        keyTarget: _categoryButtonKey,
        alignSkip: Alignment.bottomCenter,
        contents: [
          TargetContent(
            align: ContentAlign.right,
            builder: (context, controller) => Text(
              'You can slide into category',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'settingsButton',
        keyTarget: _sortButtonKey,
        alignSkip: Alignment.bottomCenter,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => Text(
              'You can sort your dishes by using this',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    ];

    final tutorial = TutorialCoachMark(
      targets: targets,
    );

    // Show the tutorial after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      tutorial.show(context: context);

      // Once the tutorial is shown, set the flag in SharedPreferences
      prefs.setBool('tutorialShowndishes', true);
    });
  }

  // Pick an image from the gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> generateAIImage(String serial) async {
    // Get the prompt from the TextField
    String prompt = textController.text.isNotEmpty
        ? textController.text
        : 'food'; // Default prompt if empty

    var headers = {
      'Authorization':
          'Bearer vk-y5TVB2IIbx3NR14FFMejRTP522iUQFw2X4N0qwF9sUDD8CWm'
    };

    var request = http.MultipartRequest(
        'POST', Uri.parse('https://api.vyro.ai/v2/image/generations'));

    request.fields.addAll({
      'prompt': prompt,
      'style': 'realistic',
      'aspect_ratio': '4:3',
      'seed': '5'
    });

    request.headers.addAll(headers);

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        // Check if the response is an image
        var contentType = response.headers['content-type'] ?? '';

        if (contentType.contains('image')) {
          var bytes = await response.stream.toBytes();
          setState(() async {
            _imageBytes = bytes;
            // await _uploadToCloudinaryFromAI(_imageBytes!, serial);
          });
        } else {
          var responseBody = await response.stream.bytesToString();
          print("Received text response: $responseBody");
        }
      } else {
        print('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _uploadToCloudinaryFromAI(
      Uint8List imageBytes, String serial) async {
    try {
      const cloudinaryUrl =
          'https://api.cloudinary.com/v1_1/dcrm8qosr/image/upload';
      const preset = 'Flutter';

      final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
      request.fields['upload_preset'] = preset;

      // Convert Uint8List to MultipartFile
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: '$serial.jpg', // Give it a name
        contentType: MediaType('image', 'jpeg'),
      ));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);

        setState(() {
          _uploadedImageUrl = jsonResponse['secure_url'];
          _publicId = jsonResponse['public_id'];
        });

        print('Image uploaded successfully: $_uploadedImageUrl');
        print('Public ID: $_publicId');
      } else {
        print('Image upload failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during image upload: $e');
    }
  }

  Future<void> _uploadImage(String serial) async {
    if (_image == null) return;

    try {
      // Rename the file before uploading
      final directory = _image!.parent;
      final renamedFile = File('${directory.path}/$serial.jpg');

      if (renamedFile.existsSync()) {
        renamedFile
            .deleteSync(); // Avoid conflicts by deleting any existing file with the same name
      }

      _image!.copySync(renamedFile.path);

      print('Before rename: ${_image!.path}');
      print('After rename: ${renamedFile.path}');

      const cloudinaryUrl =
          'https://api.cloudinary.com/v1_1/dcrm8qosr/image/upload';
      const preset = 'Flutter';

      final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
      request.fields['upload_preset'] = preset;
      request.files
          .add(await http.MultipartFile.fromPath('file', renamedFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);

        setState(() {
          _uploadedImageUrl = jsonResponse['secure_url'];
          _publicId = jsonResponse['public_id'];
        });

        print('Image uploaded successfully: $_uploadedImageUrl');
        print('Public ID: $_publicId');
        _image = null;
      } else {
        print('Image upload failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during file renaming or uploading: $e');
    }
  }

  Future<void> _deleteImage(String serial) async {
    _publicId = serial;
    if (_publicId == null) {
      print('No image to delete.');
      return;
    }

    try {
      final timestamp =
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      const cloudinarySecret =
          'E3arq8D_VZ2sJcgbFgSvtI0jGTc'; // Replace with your Cloudinary API secret
      final String signatureString =
          'public_id=$_publicId&timestamp=$timestamp$cloudinarySecret';
      final String signature =
          sha1.convert(utf8.encode(signatureString)).toString();

      const cloudinaryDeleteUrl =
          'https://api.cloudinary.com/v1_1/dcrm8qosr/image/destroy'; // Replace with your cloud name

      final response = await http.post(
        Uri.parse(cloudinaryDeleteUrl),
        body: {
          'public_id': _publicId!,
          'api_key': '647275926686889', // Replace with your Cloudinary API key
          'timestamp': timestamp,
          'signature': signature,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['result'] == 'ok') {
          print('Image deleted successfully.');
          setState(() {
            _uploadedImageUrl = null;
            _publicId = null;
          });
        } else {
          print('Image deletion failed: ${jsonResponse['result']}');
        }
      } else {
        print(
            'Failed to delete image: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error during image deletion: $e');
    }
  }

  Future<void> isImageUrlValid(String serial) async {
    if (_image == null && ai == false) return;
    try {
      // Construct the URL
      final url = Uri.parse(
          'https://res.cloudinary.com/dcrm8qosr/image/upload/v12345/$serial.jpg');

      // Send a HEAD request to check if the image exists
      final response = await http.head(url);

      // If the status code is 200, it means the image exists
      if (response.statusCode == 200) {
        await _deleteImage(serial);
        if (!ai) {
          await _uploadImage(serial.toString());
        } else {
          await generateAIImage(serial.toString());
          await _uploadToCloudinaryFromAI(_imageBytes!, serial.toString());
        }
      } else {
        if (!ai) {
          await _uploadImage(serial.toString());
        } else {
          await generateAIImage(serial.toString());
          await _uploadToCloudinaryFromAI(_imageBytes!, serial.toString());
        }
      }
    } catch (e) {
      print('Error checking image URL: $e');
    }
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.05,
            width: MediaQuery.of(context).size.width * 0.07,
            decoration: BoxDecoration(
              color: colorList[int.parse(widget.type!) -
                  1], // Set the background color to orange
              borderRadius: BorderRadius.circular(15), // Match dialog shape
            ),
            padding: const EdgeInsets.all(0.0),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Creating",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Set text color to white
                  ),
                ),
                SizedBox(width: 16),
                CircularProgressIndicator(
                  strokeWidth: 5,
                  color: Colors.white, // Set progress indicator color to white
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showUpdatingingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.05,
            width: MediaQuery.of(context).size.width * 0.07,
            decoration: BoxDecoration(
              color: colorList[int.parse(widget.type!) -
                  1], // Set the background color to orange
              borderRadius: BorderRadius.circular(15), // Match dialog shape
            ),
            padding: const EdgeInsets.all(0.0),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Updating",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Set text color to white
                  ),
                ),
                SizedBox(width: 16),
                CircularProgressIndicator(
                  strokeWidth: 5,
                  color: Colors.white, // Set progress indicator color to white
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteDatabase = context.watch<database>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Adjust sizes dynamically
    final iconSize =
        screenWidth * 0.08; // Adjust icon size based on screen width
    final titleFontSize = screenWidth * 0.1;
    _filterAndSortNotes();
    //readDishes(widget.type!);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colorList[int.parse(widget.type!) - 1],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.075),
        child: GestureDetector(
          onVerticalDragEnd: (details) {
            // Check the swipe direction (down)
            if (details.velocity.pixelsPerSecond.dy > 500) {
              Navigator.pop(context);
            }
          },
          child: AppBar(
            toolbarHeight: screenHeight * 0.08,
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            leading: Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.015, left: 10),
              child: IconButton(
                icon: Icon(FontAwesomeIcons.arrowDown, size: iconSize),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            title: Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.015),
              child: Text(
                widget.title!,
                style: GoogleFonts.poppins(
                  fontSize: titleFontSize,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
      /* floatingActionButton: FloatingActionButton(
        key: _floatingButtonKey,
        onPressed: createDish,
        shape: const CircleBorder(),
        backgroundColor: const Color.fromARGB(255, 38, 159, 224),
        child: Icon(Icons.add,
            size: 30, color: Theme.of(context).colorScheme.inversePrimary),
      ), */
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context)
              .unfocus(); // Dismiss the keyboard and unfocus the search bar
        },
        /* onVerticalDragDown: (DragDownDetails details) {
          Navigator.pop(context);
        }, */
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add a search bar at the top of the screen

            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.035),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                              15.0), // All corners rounded
                          // Rounded except top-right and bottom-right
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.transparent,
                              spreadRadius: 0,
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(0),
                              width: MediaQuery.of(context).size.width * 0.11,
                              height:
                                  MediaQuery.of(context).size.height * 0.035,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: !_isSearchVisible
                                    ? BorderRadius.circular(
                                        15.0) // All corners rounded
                                    : const BorderRadius.only(
                                        topLeft: Radius.circular(15.0),
                                        bottomLeft: Radius.circular(15.0),
                                      ), // Rounded except top-right and bottom-right
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.transparent,
                                    spreadRadius: 0,
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(
                                        MediaQuery.of(context).size.width *
                                            0.001),
                                    child: IconButton(
                                      icon: Icon(
                                        _isSearchVisible
                                            ? Icons.arrow_back
                                            : Icons.search,
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.05,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isSearchVisible = !_isSearchVisible;

                                          if (!_isSearchVisible) {
                                            _searchController.clear();
                                            searchQuery = '';
                                            _filterAndSortNotes();
                                          }
                                        });

                                        if (_isSearchVisible) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            FocusScope.of(context)
                                                .requestFocus(_focusNode);
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: _isSearchVisible
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 0.0),
                                      child: Container(
                                        margin: const EdgeInsets.all(0),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.81,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.035,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.03),
                                            bottomRight: Radius.circular(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.03),
                                            topLeft: Radius.circular(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.03),
                                            bottomLeft: Radius.circular(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.03),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              spreadRadius: 0,
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: _searchController,
                                                focusNode: _focusNode,
                                                decoration: InputDecoration(
                                                  hintText: 'Search Dishes',
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    vertical: 8,
                                                    horizontal: 12,
                                                  ),
                                                  suffixIcon: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(
                                                          Ionicons.close_circle,
                                                          color: Colors.grey,
                                                          size: 20,
                                                        ),
                                                        onPressed: () {
                                                          _searchController
                                                              .clear();
                                                          setState(() {
                                                            searchQuery = '';
                                                            _filterAndSortNotes();
                                                          });
                                                        },
                                                      ),
                                                      const Text('|'),
                                                      IconButton(
                                                        icon: Icon(
                                                          _isListening
                                                              ? Icons.mic
                                                              : Icons.mic_none,
                                                          color: _isListening
                                                              ? Colors.red
                                                              : Colors.grey,
                                                          size: 20,
                                                        ),
                                                        onPressed: !_isListening
                                                            ? _startListening
                                                            : _stopListening,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                onChanged: (value) {
                                                  setState(() {
                                                    searchQuery =
                                                        value.toLowerCase();
                                                    _filterAndSortNotes();
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                      /*  SizedBox(
                          width: _isSearchVisible
                              ? MediaQuery.of(context).size.width * 0.01
                              : MediaQuery.of(context).size.width * 0.14), */
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Your existing toggle switch

                                AnimatedToggleSwitch<int>.size(
                                  key: _categoryButtonKey,
                                  textDirection: TextDirection.rtl,
                                  current: _currentIndex,
                                  values: const [2, 1, 0],
                                  iconOpacity: 0.50,
                                  height: MediaQuery.of(context).size.height *
                                      0.035,
                                  indicatorSize: const Size.fromWidth(37),
                                  spacing: 0,
                                  iconBuilder: iconBuilder,
                                  borderWidth: 1.0,
                                  iconAnimationType: AnimationType.onHover,
                                  style: ToggleStyle(
                                    borderColor: Colors.transparent,
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width *
                                            0.03),
                                    boxShadow: [
                                      const BoxShadow(
                                        color: Colors.black26,
                                        spreadRadius: 0,
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  styleBuilder: (i) => ToggleStyle(
                                    indicatorColor: colorBuilder(i),
                                  ),
                                  onChanged: (i) {
                                    setState(() {
                                      _currentIndex = i;
                                      _filterAndSortNotes(); // Apply filter and sort
                                      //  print(i); // Debug print
                                    });
                                  },
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.01),

                                // Your existing dropdown for sorting
                                GestureDetector(
                                  onTap: () {
                                    DropDownState(
                                      DropDown(
                                        isDismissible: true,
                                        isSearchVisible: false,
                                        bottomSheetTitle: Text(
                                          'Sort Options',
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20.0),
                                        ),
                                        submitButtonChild: Text(
                                          'Done',
                                          style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        clearButtonChild: Text(
                                          'Clear',
                                          style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        data: _sortingOptions,
                                        onSelected: _onSortChanged,
                                        enableMultipleSelection: false,
                                      ),
                                    ).showModal(context);
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.2, // 90% of screen width
                                    height: MediaQuery.of(context).size.height *
                                        0.035,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          MediaQuery.of(context).size.width *
                                              0.03),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 1,
                                          blurRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        //Text(dropdownValue),
                                        Text(
                                          "Sort By",
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: screenWidth * 0.03),
                                        ),
                                        const Icon(Icons.arrow_drop_down,
                                            size: 30),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.01),

                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.035,
                                  width: MediaQuery.of(context).size.width *
                                      0.2, // Set the width of the button
                                  child: ElevatedButton(
                                      key: _floatingButtonKey,
                                      onPressed: () async {
                                        await loadSerial();
                                        createDish();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.03), // Adjust the corner radius if needed
                                        ),
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                            vertical:
                                                0), // Adjust padding for height
                                      ),
                                      child: Text(
                                        "Add Dishes",
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: screenWidth * 0.03),
                                      )),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            //const SizedBox(height: 10),
            // The ListView to display the filtered notes
            Expanded(
              child: _isLoading
                  ? Center(
                      child: ColorFiltered(
                        colorFilter:
                            ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        child: Lottie.asset(
                          'assets/lottie_json/loadingspoons.json',
                          width: screenWidth * 0.4,
                        ),
                      ),
                    ) // Show loading indicator
                  : _sortededNotes.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: screenWidth * 0.3),
                            child: GestureDetector(
                              onTap: _searchController.text.isEmpty
                                  ? createDish
                                  : null,
                              child: Column(
                                children: [
                                  Lottie.asset(
                                    selectedLottie,
                                    width: screenWidth * 0.5,
                                  ),
                                  const SizedBox(
                                    height: 0,
                                  ),
                                  Text(
                                    'No Dishes Found',
                                    style: GoogleFonts.poppins(
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    _searchController.text.isEmpty
                                        ? 'Tap to Add'
                                        : '',
                                    style: GoogleFonts.poppins(
                                      fontSize: screenWidth * 0.03,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ), // Show this if list is empty
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: ListView.builder(
                            itemCount: _sortededNotes.length,
                            itemBuilder: (context, index) {
                              final note = _sortededNotes[index];

                              return GestureDetector(
                                onLongPress: () {
                                  // Call your update function when a long press is detected
                                  updateDish(note, widget.type!, note.name);
                                },
                                onTap: () {
                                  setState(() {
                                    Navigator.of(context).push(PageTransition(
                                        curve: Curves.linear,
                                        type: PageTransitionType.rightToLeft,
                                        duration: const Duration(
                                            milliseconds:
                                                300), // Adjust duration to slow down the transition
                                        child: smallrecipe(
                                          serial: note.serial,
                                          type: widget.type,
                                          dish: note.name,
                                          category: note.category,
                                          access: true,
                                          imageURL: note.imageUrl,
                                          background: colorList[
                                              int.parse(widget.type!) - 1],
                                        )));
                                  });
                                },
                                child: DishTile(
                                  duration: note.duration,
                                  category: note.category,
                                  dish: note.name,
                                  type: widget.type,
                                  text: note.name,
                                  fromType: 'no',
                                  serial: note.serial,
                                  imageURL: note.imageUrl,
                                  onEditPressed: () => updateDish(
                                      note, widget.type!, note.name!),
                                  onDeletePressed: () => deleteNote(
                                      note.id, widget.type!, note.name),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frino_icons/frino_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:recipe/collections/names.dart';
import 'package:recipe/models/br_database.dart';
import 'package:recipe/models/crazy_switch.dart';
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
    const Color.fromARGB(255, 249, 168, 37), // #F9A825
    const Color.fromARGB(255, 102, 187, 106), // #66BB6A
    const Color.fromARGB(255, 183, 28, 28), // #B71C1C
    const Color.fromARGB(255, 141, 110, 99), // #8D6E63
    const Color.fromARGB(255, 255, 128, 171), // #FF80AB
    const Color.fromARGB(255, 255, 112, 67), // #FF7043
    const Color.fromARGB(255, 195, 176, 153), // #C3B099
    const Color.fromARGB(255, 79, 195, 247), // #4FC3F7
    const Color.fromARGB(255, 104, 159, 56), // #689F38
    const Color.fromARGB(255, 179, 157, 219), // #B39DDB
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

  @override
  void initState() {
    super.initState();

    _createTutorial();
    Timer(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
    readDishes(widget.type!);
    loadSerial();
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
                const Text(
                  "New Dish",
                  style: TextStyle(
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
                        hintStyle: TextStyle(
                            fontSize: 16, color: Colors.grey.shade600),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  // Show error message if text field is empty
                  if (isTextFieldEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        'Please enter a dish name.',
                        style: TextStyle(
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
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 16),
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
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    // Check if the text field is empty
                    isTextFieldEmpty = textController.text.isEmpty;
                  });

                  if (!isTextFieldEmpty) {
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
                        );

                    duration = selectedDurationHours.toStringAsFixed(1);
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
                child: const Text(
                  'Create',
                  style: TextStyle(
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
                    const Text(
                      "Update Dish",
                      style: TextStyle(
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
                                onPressed: () {
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
                        hintStyle: TextStyle(
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
                      style: const TextStyle(
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
                        style: TextStyle(
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
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 16,
                          ),
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
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('Cancel'),
              ),
              // Update Button
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    // Check if the text field is empty
                    isTextFieldEmpty = textController.text.isEmpty;
                  });
                  if (textController.text.isNotEmpty) {
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
                        );

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
                child: const Text(
                  'Update',
                  style: TextStyle(
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
        return FontAwesomeIcons.bowlRice; // Default FontAwesome icon
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
    readDishes(widget.type!);

    return Scaffold(
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
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      _isSearchVisible
                                          ? Icons.arrow_back
                                          : Icons.search,
                                      size: MediaQuery.of(context).size.width *
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
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(15.0),
                                            bottomRight: Radius.circular(15.0),
                                            topLeft: Radius.circular(15.0),
                                            bottomLeft: Radius.circular(15.0),
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
                                    borderRadius: BorderRadius.circular(15.0),
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
                                        bottomSheetTitle: const Text(
                                          'Sort Options',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20.0),
                                        ),
                                        submitButtonChild: const Text(
                                          'Done',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        clearButtonChild: const Text(
                                          'Clear',
                                          style: TextStyle(
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
                                      borderRadius: BorderRadius.circular(15.0),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 1,
                                          blurRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.only(left: 5.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          //Text(dropdownValue),
                                          Text(
                                            "Sort By",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Icon(Icons.arrow_drop_down, size: 30),
                                        ],
                                      ),
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
                                      onPressed: createDish,
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              15.0), // Adjust the corner radius if needed
                                        ),
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                            vertical:
                                                0), // Adjust padding for height
                                      ),
                                      child: const Text(
                                        "Add Dishes",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
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
                              onEditPressed: () =>
                                  updateDish(note, widget.type!, note.name!),
                              onDeletePressed: () =>
                                  deleteNote(note.id, widget.type!, note.name),
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

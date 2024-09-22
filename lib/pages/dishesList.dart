import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frino_icons/frino_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:provider/provider.dart';
import 'package:recipe/collections/names.dart';
import 'package:recipe/models/br_database.dart';
import 'package:recipe/models/isar_instance.dart';
import 'package:recipe/pages/recipe.dart';
import 'package:recipe/models/breakfast_tile.dart';
import 'package:recipe/pages/home.dart';
import 'package:animated_switch/animated_switch.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class dishesList extends StatefulWidget {
  dishesList({super.key, required this.type, required this.title});
  String? type;
  String? title;

  State<dishesList> createState() => _dishesListState();
}

class _dishesListState extends State<dishesList> {
  //text controller to access what the user typed
  TextEditingController textController = TextEditingController();
  final isar = IsarInstance().isar;
  List<Dish> _filteredNotes = [];
  List<Dish> _sortededNotes = [];
  List<Title> currentTitles = [];
  late SharedPreferences prefs;

  String dropdownValue = 'A-Z'; // Class-level variable
  int? serial = 0;
  List<bool> _isSelected = [true, false, false]; // Default to filter by all
  int _currentIndex = 0;
  String? dishName;

  @override
  void initState() {
    super.initState();
    _createTutorial();
    // on app startup, fetch the existing notes
    readNotes(widget.type!);
    readTitles(widget.type!);
    loadSerila();
  }

  Future<void> loadSerila() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      serial = prefs.getInt('serial') ?? 0;
    });
  }

  Future<void> saveSerial(int num) async {
    setState(() {
      serial = num;
    });
    await prefs.setInt('serial', num);
  }

  //function to create a note
  void createDish() {
    String? selectedOption;
    double selectedDurationHours = 1.0; // Start with 1 hour
    bool isSwitched = false;
    String category = '0';
    String? duration;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text(
              "New Dish",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // First TextField
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                        hintText: 'Dish name',
                        hintStyle: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w500)),
                  ),
                ),
                const SizedBox(height: 25),
                // Slider for Duration Selector
                const Padding(
                  padding: EdgeInsets.only(right: 115),
                  child: Text("Select Duration",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
                ),
                Row(
                  children: [
                    // SizedBox(width: 8,),

                    Slider(
                      value: selectedDurationHours,
                      min: 0.5,
                      max: 5,
                      divisions: 9, // Allow 30-minute intervals
                      onChanged: (value) {
                        // Update the slider's value
                        setState(() {
                          selectedDurationHours = value;
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Text(
                          '${selectedDurationHours.toStringAsFixed(1)} hrs'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ToggleSwitch(
                    minWidth: 110.0,
                    initialLabelIndex: 0,
                    cornerRadius: 20.0,
                    activeFgColor: Colors.white,
                    inactiveBgColor: Colors.grey,
                    inactiveFgColor: Colors.white,
                    totalSwitches: 2,
                    labels: ['Veg', 'Non-Veg'],
                    //icons: [I.mars, FontAwesomeIcons.venus],
                    activeBgColors: [
                      [Colors.green],
                      [Colors.red]
                    ],
                    onToggle: (index) {
                      print('switched to: $index');
                      category = index.toString();
                    },
                  ),
                ),
              ],
            ),
            actions: [
              // Create button
              MaterialButton(
             
                textColor: Colors.white,
                onPressed: () {
                  serial;
                  int incrementedSearial = (serial! + 1);
                  saveSerial(incrementedSearial);
                  if (textController.text.isNotEmpty) {
                    final now = DateTime.now();
                    final date =
                        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                    final time =
                        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

                    context.read<database>().addType(
                          serial.toString(),
                          textController.text,
                          widget.type!,
                          selectedDurationHours.toStringAsFixed(1),
                          category,
                          date,
                          time,
                        );

                    duration = selectedDurationHours.toStringAsFixed(1);
                    // Use selectedDurationHours and selectedOption as needed

                    Navigator.pop(context);
                    textController.clear();
                  }
                },
                child: Text('Create',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary)),
              )
            ],
          );
        },
      ),
    );
  }

  //read notes
  void readNotes(String type) {
    context.read<database>().fetchNotes(type);
  }

  Future<void> readTitles(String type) async {
    final header = await context.read<database>().fetchtitlesFromIsar(type);
    print("object::::: $header");
  }

  //update note
  void updateNote(Dish name, String type) {
    String category = name.category!; // Default value
    String selectedDurationHours = name.duration!; // Default duration

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Update Dish",
                  style: TextStyle(fontWeight: FontWeight.bold),
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
                              deleteNote(name.id, widget.type!);
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
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                )
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dish Name TextField
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: textController..text = name.name,
                    decoration: const InputDecoration(
                        hintText: 'Dish name',
                        hintStyle: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w500)),
                  ),
                ),
                const SizedBox(height: 25),
                // Slider for Duration Selector
                const Padding(
                  padding: EdgeInsets.only(right: 115),
                  child: Text("Select Duration",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
                ),
                Row(
                  children: [
                    Slider(
                      value: double.parse(selectedDurationHours),
                      min: 0.5,
                      max: 5,
                      divisions: 9, // Allow 30-minute intervals
                      onChanged: (value) {
                        setState(() {
                          selectedDurationHours = value.toStringAsFixed(1);
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Text('${selectedDurationHours} hrs'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ToggleSwitch(
                    minWidth: 110.0,
                    initialLabelIndex: int.parse(category),
                    cornerRadius: 20.0,
                    activeFgColor: Colors.white,
                    inactiveBgColor: Colors.grey,
                    inactiveFgColor: Colors.white,
                    totalSwitches: 2,
                    labels: ['Veg', 'Non-Veg'],
                    activeBgColors: [
                      [Colors.green],
                      [Colors.red]
                    ],
                    onToggle: (index) {
                      setState(() {
                        category = index.toString();
                      });
                    },
                  ),
                ),
              ],
            ),
            actions: [
              // Update button
              MaterialButton(
                textColor: Colors.white,
                onPressed: () {
                  final now = DateTime.now();
                  final date =
                      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                  final time =
                      '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
                  if (textController.text.isNotEmpty) {
                    context.read<database>().updateNote(
                        name.id,
                        textController.text,
                        type,
                        selectedDurationHours,
                        category,
                        date,
                        time);
                    // Clear the controller
                    textController.clear();
                    // Pop the dialog box
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  'Update',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'close',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  //delete a note
  void deleteNote(int id, String type) {
    context.read<database>().deleteNote(id, widget.type!);
  }

  void _filterAndSortNotes() {
    final noteDatabase = context.read<database>();

    // Apply filtering
    _filteredNotes = noteDatabase.currentNames.where((note) {
      if (_currentIndex == 0) {
        return true; // Show all items
      } else if (_currentIndex == 1) {
        return note.category == '1'; // Filter by `category == 1`
      } else if (_currentIndex == 2) {
        return note.category == '0'; // Filter by `category == 0`
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
    return Icon(iconDataByValue(value));
  }

  IconData iconDataByValue(int? value) => switch (value) {
        0 => Icons.restaurant_menu,
        1 => FrinoIcons.f_meat,
        2 => FrinoIcons.f_leaf,
        _ => Icons.lightbulb_outline_rounded,
      };

  Widget sizeIconBuilder(BuildContext context,
      AnimatedToggleProperties<int> local, GlobalToggleProperties<int> global) {
    return iconBuilder(local.value);
  }

  Color colorBuilder(int value) => switch (value) {
        0 => const Color.fromARGB(255, 96, 143, 230),
        1 => Colors.red,
        2 => Colors.green,
        _ => Colors.red,
      };

  Widget coloredRollingIconBuilder(int value, bool foreground) {
    final color = foreground ? colorBuilder(value) : null;
    return Icon(
      iconDataByValue(value),
      color: color,
    );
  }

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

    // Update notes based on selected filter and sort
    _filterAndSortNotes();

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(
            100.0), // Increase the height to fit the content
        child: AppBar(
          toolbarHeight: 100,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
          leading: Padding(
            padding: const EdgeInsets.only(top: 25.0, left: 10),
            child: IconButton(
              icon: const Icon(FontAwesomeIcons.anglesLeft, size: 40),
              onPressed: () {
                Navigator.pop(context); // Navigate back when pressed
              },
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(
                top: 20.0), // Add bottom padding to push content down
            child: Text(
              widget.title!,
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 50,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),
        ),
      ),
/*       drawer: Drawer(
        surfaceTintColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 230, 228, 228),
        shadowColor: Colors.white,
        elevation: 50,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 100, // Set the height you want
              child: DrawerHeader(
                padding: EdgeInsets.only(top: 30, left: 20),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade50,
                ),
                child: Text('Menu',
                    style: GoogleFonts.dmSerifDisplay(
                        fontSize: 40,
                        color: Theme.of(context).colorScheme.inversePrimary)),
              ),
            ),

            // Breakfast Card
            SimpleGestureDetector(
              onTap: () {
                setState(() {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => dishesList(type: '1',title: ''),
                    
                  ));
                });
              },
              swipeConfig: const SimpleSwipeConfig(
                verticalThreshold: 40.0,
                horizontalThreshold: 40.0,
                swipeDetectionBehavior:
                    SwipeDetectionBehavior.continuousDistinct,
              ),
              child: Card(
                color: const Color.fromARGB(255, 242, 203, 160),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(
                    color: Colors.transparent,
                    width: 2.0,
                  ),
                ),
                child: const SizedBox(
                  width: 170,
                  height: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Text(
                          "Breakfast",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: Icon(
                          Ionicons.fast_food_outline,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Lunch Card
            SimpleGestureDetector(
              onTap: () {
                setState(() {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => dishesList(type: '2', title: widget.title,),
                  ));
                });
              },
              swipeConfig: const SimpleSwipeConfig(
                verticalThreshold: 40.0,
                horizontalThreshold: 40.0,
                swipeDetectionBehavior:
                    SwipeDetectionBehavior.continuousDistinct,
              ),
              child: Card(
                color: Color.fromARGB(255, 217, 212, 182),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(
                    color: Colors.transparent,
                    width: 2.0,
                  ),
                ),
                child: const SizedBox(
                  width: 170,
                  height: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Text(
                          "Lunch",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: Icon(
                          Ionicons.bag_outline,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Dinner Card
            SimpleGestureDetector(
              onTap: () {
                setState(() {
                   Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => dishesList(type: '3',title: widget.title),
                    
                  ));
                 
                });
              },
              swipeConfig: const SimpleSwipeConfig(
                verticalThreshold: 40.0,
                horizontalThreshold: 40.0,
                swipeDetectionBehavior:
                    SwipeDetectionBehavior.continuousDistinct,
              ),
              child: Card(
                color: Color.fromARGB(255, 240, 184, 213),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(
                    color: Colors.transparent,
                    width: 2.0,
                  ),
                ),
                child: const SizedBox(
                  width: 170,
                  height: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Text(
                          "Dinner",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: FaIcon(
                          FontAwesomeIcons.bowlFood,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ), */

      floatingActionButton: FloatingActionButton(
        key: _floatingButtonKey,
        onPressed: createDish,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add,
            color: Theme.of(context).colorScheme.inversePrimary),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /* Padding(
            padding: const EdgeInsets.only(left: 25, top: 20),
            child: Text(widget.title!,
                style: GoogleFonts.dmSerifDisplay(
                    fontSize: 48,
                    color: Theme.of(context).colorScheme.inversePrimary)),
          ), */
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25.0, top: 10),
                child: AnimatedToggleSwitch<int>.size(
                  key: _categoryButtonKey,
                  textDirection: TextDirection.rtl,
                  current: _currentIndex,
                  values: const [2, 1, 0],
                  iconOpacity: 0.50,
                  height: 50,
                  indicatorSize: const Size.fromWidth(40),
                  spacing: 0,
                  iconBuilder: iconBuilder,
                  borderWidth: 7.0,
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
                      print(i); // Debug print
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 25.0, top: 10),
                child: Container(
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
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        key: _sortButtonKey,
                        menuWidth: 125,
                        borderRadius: BorderRadius.circular(20.0),
                        value: dropdownValue,
                        items: <String>[
                          'A-Z',
                          'Z-A',
                          'Shortest',
                          'Longest',
                          'Newest',
                          'Oldest'
                        ].map<DropdownMenuItem<String>>((String value) {
                          Icon trailingIcon;
                          switch (value) {
                            case 'A-Z':
                              trailingIcon = const Icon(
                                CupertinoIcons.sort_up,
                                size: 17,
                              );
                              break;
                            case 'Z-A':
                              trailingIcon = const Icon(
                                CupertinoIcons.sort_down,
                                size: 17,
                              );
                              break;
                            case 'Shortest':
                              trailingIcon = const Icon(
                                  CupertinoIcons.timer_fill);
                              break;
                            case 'Longest':
                              trailingIcon = const Icon(
                                  CupertinoIcons.timer_fill);
                              break;
                            case 'Newest':
                              trailingIcon = const Icon(CupertinoIcons.today);
                              break;
                            case 'Oldest':
                              trailingIcon = const Icon(
                                Icons.date_range,
                              );
                              break;
                            default:
                              trailingIcon = const Icon(Icons.label);
                          }

                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(value),
                                trailingIcon,
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                            _filterAndSortNotes(); // Apply filter and sort
                          });
                        },
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GestureDetector(
              child: ListView.builder(
                itemCount: _sortededNotes.length,
                itemBuilder: (context, index) {
                  final note = _sortededNotes[index];

                  return GestureDetector(
                    onLongPress: () {
                      // Call your update function when a long press is detected
                      updateNote(note, widget.type!);
                    },
                    onTap: () {
                      setState(() {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => recipe(
                                  serial: note.serial,
                                  type: widget.type,
                                  dish: note.name,
                                )));
                      });
                    },
                    child: DishTile(
                      duration: note.duration,
                      category: note.category,
                      dish: note.name,
                      type: widget.type,
                      text: note.name,
                      onEditPressed: () => updateNote(note, widget.type!),
                      onDeletePressed: () => deleteNote(note.id, widget.type!),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

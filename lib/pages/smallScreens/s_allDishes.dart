import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frino_icons/frino_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:recipe/collections/ingredients.dart';
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

class smallalldishesList extends StatefulWidget {
  smallalldishesList({super.key, required this.title, required this.scafColor});
  String? title;
  Color? scafColor;

  State<smallalldishesList> createState() => _smallalldishesListState();
}

class _smallalldishesListState extends State<smallalldishesList> {
  //text controller to access what the user typed
  TextEditingController textController = TextEditingController();
  final isar = IsarInstance().isar;
  List<Dish> _filteredNotes = [];
  List<Ingredients> _filteredByIng = [];
  List<Dish> _sortededNotes = [];
  List<Title> sortedTitles = [];
  Set<String> selectedIngredients = <String>{};
  List<String> selectedSerials = []; // Change to a List instead of Set
  List<String> finalSerials = [];
  bool _isSearchVisible = false;
  final FocusNode _focusNode = FocusNode();

  late SharedPreferences prefs;

  String dropdownValue = 'A-Z'; // Class-level variable
  int? serial = 0;
  List<bool> _isSelected = [true, false, false]; // Default to filter by all
  int _currentIndex = 0;
  String? dishName;
  TextEditingController _searchController = TextEditingController();
  TextEditingController _searchControllerIng = TextEditingController();

  String searchQuery = '';
  String searchQueryIng = '';
  List<SelectedListItem> _filterOptions = [];

  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isLoading = true; // Manage loading state

  final List<SelectedListItem> _sortingOptions = [
    SelectedListItem(name: 'A to Z', value: 'A-Z'),
    SelectedListItem(name: 'Z to A', value: 'Z-A'),
    SelectedListItem(name: 'By Type', value: 'By Type'),
    SelectedListItem(name: 'Shortest', value: 'Shortest'),
    SelectedListItem(name: 'Longest', value: 'Longest'),
    SelectedListItem(name: 'Newest', value: 'Newest'),
    SelectedListItem(name: 'Oldest', value: 'Oldest'),
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

  Future<void> _onFilterChanged(List<dynamic> selectedList) async {
    if (selectedList.isNotEmpty) {
      selectedIngredients.clear();
      selectedSerials.clear();
      finalSerials.clear();
      for (int i = 0; i < selectedList.length; i++) {
        final String selectedValue =
            selectedList[0].name; // Get the name of the selected item
        final response = await Supabase.instance.client
            .from('ingredients')
            .select()
            .eq('name', selectedList[i].name);
        print('lengthof: ${selectedList.length}');
        final data = List<Map<String, dynamic>>.from(response);

        setState(() {
          _addIngredientAndSerials(selectedList[i].name, data);

          // Always update finalSerials after any operation
        });
      }
      _updateFinalSerialsForCycle();

      // Apply filter and sort
    } else {
      finalSerials.clear();
      selectedIngredients.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    _createTutorial();
    fetchSortingOptions();

    Timer(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
    readDishes();
    loadSerial();
    _filterbying();
    _speech = stt.SpeechToText();
  }

  Future<void> fetchSortingOptions() async {
final response = await supabase
    .from('ingredients')
    .select()
    .order('name', ascending: true); // Sort in ascending order by 'name'

    setState(() {
      _filterOptions = response
          .map<SelectedListItem>(
            (item) => SelectedListItem(
              name: item['name'] as String,
              value: item['name'] as String,
            ),
          )
          .toList();
    });
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

        await Future.delayed(const Duration(seconds: 7)); // Minimum wait time
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
    print(serial);
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

  //read notes
  void readDishes() async {
    await context.read<database>().fetchAllDishes();
    _filterbying();
  }

  Future<void> _filterbying() async {
    final noteDatabase = context.read<database>();

    _filteredByIng = noteDatabase.currentAllIng.where((note) {
      // Check if the note name matches the search query
      final matchesSearch =
          note.name!.toLowerCase().contains(searchQueryIng.toLowerCase());

      // Check if the serial matches the selected serials
      final matchesSerial =
          selectedSerials.isEmpty || selectedSerials.contains(note.serial);

      // Filter based on the current index (category filtering logic)
      if (_currentIndex == 0) {
        return matchesSearch && matchesSerial; // Match search and serial
      } else if (_currentIndex == 1) {
        return note.category == '1' &&
            matchesSearch &&
            matchesSerial; // Category 1, search, and serial
      } else if (_currentIndex == 2) {
        return note.category == '0' &&
            matchesSearch &&
            matchesSerial; // Category 0, search, and serial
      }

      return false; // Default case: no match
    }).toList();

    // Sort the filtered list alphabetically by note name
    _filteredByIng
        .sort((a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase()));
  }

  void _filterAndSortNotes() {
    final noteDatabase = context.read<database>();

    // Apply filtering
    _filteredNotes = noteDatabase.currentNames.where((note) {
      final matchesSearch =
          note.name.toLowerCase().contains(searchQuery.toLowerCase());

      // Check if note.serial contains any of the selected serials
      final matchesSerial = finalSerials.isEmpty ||
          finalSerials.any((serial) => note.serial!.contains(serial));

      if (_currentIndex == 0) {
        return matchesSearch &&
            matchesSerial; // Show all items that match search and serial
      } else if (_currentIndex == 1) {
        return note.category == '1' &&
            matchesSearch &&
            matchesSerial; // Filter by category == 1, search, and serial
      } else if (_currentIndex == 2) {
        return note.category == '0' &&
            matchesSearch &&
            matchesSerial; // Filter by category == 0, search, and serial
      }
      return false; // Default case
    }).toList();

    //

    //

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
    } else if (dropdownValue == 'By Type') {
      _sortededNotes.sort((a, b) => a.type!.compareTo(b.type!)); // Short-Long
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
        //return FontAwesomeIcons.bowlRice; // Default FontAwesome icon
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

  Future<void> _loadData() async {
    final noteDatabase = context.watch<database>();
    await noteDatabase.fetchAllIngredients();
    //setState(() {
    // _isLoading = false;
    //});
  }

// Function to handle selection/deselection of ingredients
  Future<void> _onIngredientSelected(
      bool? selected, String ingredient, String serial) async {
    // Fetch data from Supabase
    final response = await Supabase.instance.client
        .from('ingredients')
        .select()
        .eq('name', ingredient);
    print('lengthof: ${ingredient.length}');
    final data = List<Map<String, dynamic>>.from(response);

    setState(() {
      if (selected == true) {
        _addIngredientAndSerials(ingredient, data);
      } else {
        _removeIngredientAndSerials(ingredient, data, serial);
      }

      // Always update finalSerials after any operation
      _updateFinalSerialsForCycle();
    });
  }

  void _addIngredientAndSerials(
      String ingredient, List<Map<String, dynamic>> data) {
    if (data.isNotEmpty) {
      for (var item in data) {
        String fetchedSerial = item['serial'] ?? '';
        if (fetchedSerial.isNotEmpty &&
            !selectedSerials.contains(fetchedSerial)) {
          selectedSerials.add(fetchedSerial);
        }
      }

      if (!selectedIngredients.contains(ingredient)) {
        selectedIngredients.add(ingredient);
      }
    }
    print('Added serials: ${selectedSerials.join(', ')}');
    print('Selected ingredients: ${selectedIngredients.join(', ')}');
  }

  void _removeIngredientAndSerials(
      String ingredient, List<Map<String, dynamic>> data, String serial) {
    if (data.isNotEmpty) {
      for (var item in data) {
        String fetchedSerial = item['serial'] ?? '';
        if (fetchedSerial.isNotEmpty) {
          selectedSerials.remove(fetchedSerial);
        }
      }
    }

    selectedIngredients.remove(ingredient);
    selectedSerials.remove(serial);

    print('Remaining serials after removal: ${selectedSerials.join(', ')}');
    print('Remaining selected ingredients: ${selectedIngredients.join(', ')}');
  }

  void _updateFinalSerialsForCycle() {
    setState(() {
      /*  if (selectedIngredients.isEmpty) {
        // Clear finalSerials if no ingredients are selected
        finalSerials.clear();
      } else {
        // Compute matching serials
        final matchingSerials = selectedSerials
            .where((serial) {
              int serialCount =
                  selectedSerials.where((item) => item == serial).length;
              return serialCount == selectedIngredients.length;
            })
            .toSet()
            .toList();

        // Update finalSerials
        if (matchingSerials.isNotEmpty) {
          finalSerials = matchingSerials;
        } else {
          finalSerials = ['00']; // Add '00' if no matches exist
        }
      } */
      finalSerials = selectedSerials;
    });

    print('Final serials after update: ${finalSerials.join(', ')}');
  }

// Function to display selected ingredients or 'All' if none selected
  String _getSelectedIngredientsText() {
    if (selectedIngredients.isEmpty) {
      return 'All ingredients';
    } else {
      return selectedIngredients.join(', ');
    }
  }

  void _resetAll() {
    setState(() {
      selectedIngredients.clear();
      selectedSerials.clear();
      finalSerials.clear();
    });
    print('All data has been reset.');
    print('Selected ingredients: ${selectedIngredients.join(', ')}');
    print('Selected serials: ${selectedSerials.join(', ')}');
    print('Final serials: ${finalSerials.join(', ')}');
  }

  List<String> typeList = [
    'BreakFast',
    'Lunch',
    'Dinner',
    'Gravy',
    'Sweets',
    'Starters',
    'Snacks',
    'Beverages',
    'Salads',
    'Others'
  ];
  @override
  Widget build(BuildContext context) {
    final noteDatabase = context.watch<database>();
    final currentAllIng = noteDatabase.currentAllIng;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Adjust sizes dynamically
    final iconSize =
        screenWidth * 0.07; // Adjust icon size based on screen width
    final titleFontSize = screenWidth * 0.08;

    // Update notes based on selected filter, sort, and search
    _filterAndSortNotes();
    // _filterbying();

    readDishes();
    _loadData();

    return Scaffold(
      backgroundColor: widget.scafColor,
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
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.width > 600
                      ? 20.0
                      : MediaQuery.of(context).size.height * 0.02,
                  left: 10),
              child: IconButton(
                icon: Icon(FontAwesomeIcons.arrowDown,
                    size: MediaQuery.of(context).size.width > 600
                        ? 40
                        : iconSize),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                widget.title!,
                style: GoogleFonts.poppins(
                  fontSize: MediaQuery.of(context).size.width > 600
                      ? 50
                      : titleFontSize,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          // Check the swipe direction (down)
          if (details.velocity.pixelsPerSecond.dy > 500) {
            Navigator.pop(context);
          }
        },
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
                                      padding: EdgeInsets.only(left: 5.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          //Text(dropdownValue),
                                          Text(
                                            "Sort By",
                                            style: GoogleFonts.poppins(
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
                                GestureDetector(
                                  onTap: () {
                                    DropDownState(
                                      DropDown(
                                        data: _filterOptions,
                                        isDismissible: true,
                                        isSearchVisible: true,
                                        enableMultipleSelection: true,
                                        bottomSheetTitle: Text(
                                          'Filter',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.0,
                                          ),
                                        ),
                                        submitButtonChild: Text(
                                          'Done',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        clearButtonChild: Text(
                                          'Clear',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        bottomSheetListener: (notification) {
                                          // This ensures the dropdown expands as the user scrolls
                                          return true; // Return true to allow scrolling expansion
                                        },
                                      ),
                                    ).showModal(context);
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.25, // 90% of screen width
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
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 5.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          //Text(dropdownValue),
                                          Text(
                                            "Filter By",
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Icon(Icons.arrow_drop_down, size: 30),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
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
            const SizedBox(height: 10),
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
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /* Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(1),
                              borderRadius: BorderRadius.circular(
                                  15.0), // Adjust the value for roundness
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width *
                                        0.01,
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _resetAll();
                                      _searchControllerIng.clear();
                                      setState(() {
                                        searchQueryIng =
                                            ''; // Reset the search query
                                        _filterbying(); // Call your filtering method
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.red, // Button background color
                                      foregroundColor:
                                          Colors.white, // Text color
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            8.0), // Rounded corners
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0,
                                          vertical: 8.0), // Smaller padding
                                      minimumSize: const Size(50,
                                          30), // Ensures the button has a small size
                                    ),
                                    child: Text(
                                      'Reset All',
                                      style: GoogleFonts.poppins(
                                          fontSize: 12), // Smaller font size
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: _filteredByIng.length,
                                      itemBuilder: (context, index) {
                                        // Get the current ingredient and its associated serials
                                        final ingredient =
                                            _filteredByIng[index].name ??
                                                "Unknown Ingredient";
                                        final serials = _filteredByIng
                                            .where((item) =>
                                                item.name == ingredient)
                                            .map((item) => item.serial)
                                            .toList();

                                        return CheckboxListTile(
                                          title: Text(
                                            ingredient.length < 25
                                                ? ingredient
                                                : "${ingredient.substring(0, 16)}...",
                                            style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.03,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          value: selectedIngredients
                                              .contains(ingredient),
                                          activeColor: Colors.green,
                                          checkColor: Colors.white,
                                          onChanged: (bool? isSelected) async {
                                            if (ingredient == null) return;

                                            // Update selected serials and trigger callbacks for each
                                            for (final serial in serials) {
                                              if (serial != null) {
                                                selectedSerials.add(serial);
                                                await _onIngredientSelected(
                                                    isSelected,
                                                    ingredient,
                                                    serial);
                                              }
                                            }

                                            // Apply filtering after selection
                                            // _filterbying();

                                            // Log the updated selected ingredients for debugging
                                            print(
                                                'Selected Ingredients: ${_getSelectedIngredientsText()}');
                                          },
                                          contentPadding:
                                              const EdgeInsets.only(left: 10),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ), */
                        Expanded(
                          child: ListView.builder(
                            itemCount: _sortededNotes.length,
                            itemBuilder: (context, index) {
                              final note = _sortededNotes[index];
                              return GestureDetector(
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
                                          type: note.type,
                                          dish: note.name,
                                          category: note.category,
                                          access: false,
                                          imageURL: note.imageUrl,
                                          background: widget.scafColor,
                                        )));
                                  });
                                },
                                child: DishTile(
                                    duration: note.duration,
                                    category: note.category,
                                    dish: note.name,
                                    type: note.type,
                                    text: note.name,
                                    serial: note.serial,
                                    fromType:
                                        typeList[int.parse(note.type!) - 1]),
                              );
                            },
                          ),
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

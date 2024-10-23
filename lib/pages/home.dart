import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frino_icons/frino_icons.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:recipe/models/br_database.dart';
import 'package:recipe/notInUse/all.dart';
import 'package:recipe/pages/dishesList.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Map<String, String> initialData = {
    '1': 'Breakfast',
    '2': 'Lunch',
    '3': 'Dinner',
    '4': 'Gravy',
    '5': 'Sweets',
    '6': 'Starters',
    '7': 'Add',
    '8': 'Add',
    '9': 'Add',
    '10': 'Add',
    '11': 'Add',
    '12': 'Add',
  };

  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    
    _initFuture = _initializeCategoryLabels();
  }

  Future<void> _initializeCategoryLabels() async {
    List<Map<String, dynamic>> updatedCategories = List.from(categories);

    for (int i = 0; i < updatedCategories.length; i++) {
      final type = updatedCategories[i]['type'] as String;
      final fetchedTitles =
          await context.read<database>().fetchTitlesByType(type);

      if (fetchedTitles.isNotEmpty) {
        updatedCategories[i]['label'] = fetchedTitles.first.title;
      } else {
        updatedCategories[i]['label'] = initialData[type] ?? '';
      }
    }

    setState(() {
      categories =
          updatedCategories; // Reassign the entire list to trigger a rebuild
    });
  }

  var categories = <Map<String, dynamic>>[
    {
      'label': '',
      'type': '1',
      'icon': Ionicons.fast_food_outline,
      'color': Color.fromARGB(255, 242, 203, 160)
    },
    {
      'label': 'Lunch',
      'type': '2',
      'icon': Ionicons.bag_outline,
      'color': Color.fromARGB(255, 217, 212, 182)
    },
    {
      'label': 'Dinner',
      'type': '3',
      'icon': FontAwesomeIcons.bowlFood,
      'color': Color.fromARGB(255, 240, 184, 213)
    },
    {
      'label': 'Gravy',
      'type': '4',
      'icon': FontAwesomeIcons.hotjar,
      'color': Color.fromARGB(255, 242, 203, 160)
    },
    {
      'label': 'Sweets',
      'type': '5',
      'icon': Ionicons.ice_cream_outline,
      'color': Color.fromARGB(255, 217, 212, 182)
    },
    {
      'label': 'Starters',
      'type': '6',
      'icon': FrinoIcons.f_meat,
      'color': Color.fromARGB(255, 240, 184, 213)
    },
    {
      'label': ' ',
      'type': '7',
      'icon': Ionicons.add_circle_outline,
      'color': Color.fromARGB(255, 242, 203, 160)
    },
    {
      'label': ' ',
      'type': '8',
      'icon': Ionicons.add_circle_outline,
      'color': Color.fromARGB(255, 217, 212, 182)
    },
    {
      'label': ' ',
      'type': '9',
      'icon': Ionicons.add_circle_outline,
      'color': Color.fromARGB(255, 240, 184, 213)
    },
    {
      'label': ' ',
      'type': '10',
      'icon': Ionicons.add_circle_outline,
      'color': Color.fromARGB(255, 242, 203, 160)
    },
    {
      'label': ' ',
      'type': '11',
      'icon': Ionicons.add_circle_outline,
      'color': Color.fromARGB(255, 217, 212, 182)
    },
    {
      'label': ' ',
      'type': '12',
      'icon': Ionicons.add_circle_outline,
      'color': Color.fromARGB(255, 240, 184, 213)
    },
  ];

  void addTitle(String title, String type) {
    context.read<database>().addTitle(title, type);
    _initializeCategoryLabels(); // Refresh category labels after adding a title
  }

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  String? _text;

  void _onVerticalSwipe(SwipeDirection direction) {
    setState(() {
      if (direction == SwipeDirection.up) {
        _text = 'Swiped up!';
        print('Swiped up!');
      } else {
        _text = 'Swiped down!';
        print('Swiped down!');
      }
    });
  }

  void _onHorizontalSwipe(SwipeDirection direction) {
    setState(() {
      if (direction == SwipeDirection.left) {
        _text = 'Swiped left!';
        print('Swiped left!');
      } else {
        _text = 'Swiped right!';
        print('Swiped right!');
      }
    });
  }

  void _onLongPress() {
    setState(() {
      _text = 'Long pressed!';
      print('Long pressed!');
    });
  }

  @override
  Widget build(BuildContext context) {
  // Get screen dimensions
  double screenHeight = MediaQuery.of(context).size.height;
  double screenWidth = MediaQuery.of(context).size.width;

  return Scaffold(
    body: Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/bg.png',
            width: screenWidth, // Scale width to 70% of screen width
          height: screenHeight,
            fit: BoxFit.fill, // Ensure the background covers the screen
          ),
        ),
        FutureBuilder<void>(
          future: _initFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(height: screenHeight * 0.2), // Dynamically adjust top padding
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ..._buildCategoryRows(categories),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ],
    ),
  );
}


  List<Widget> _buildCategoryRows(List<Map<String, dynamic>> categories) {
  final List<Widget> rows = [];
  const int numColumns = 3;

  for (int i = 0; i < categories.length; i += numColumns) {
    final end = (i + numColumns < categories.length)
        ? i + numColumns
        : categories.length;
    final rowCategories = categories.sublist(i, end);

    rows.add(
      Padding(
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.015,
          horizontal: MediaQuery.of(context).size.width * 0.08, // Make horizontal padding responsive
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: rowCategories.map((category) {
            return EditableCategoryCard(
              initialIcon: category['icon'],
              color: category['color'],
              initialLabel: category['label'],
              type: category['type'],
              onAddLink: (textFromUser, type) async {
                addTitle(textFromUser, type);
                // Optionally: Refresh or update the UI after adding the link
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  return rows;
}

Widget _buildCategoryCard(
  BuildContext context, {
  required IconData icon,
  required Color color,
  required String label,
  required String type,
}) {
  // Get screen width and adjust card size
  double screenWidth = MediaQuery.of(context).size.width;
  double cardWidth = screenWidth * 0.4; // Adjust card width based on screen size
  double cardHeight = cardWidth; // Keep the card square based on the width

  return SimpleGestureDetector(
    onVerticalSwipe: _onVerticalSwipe,
    onHorizontalSwipe: _onHorizontalSwipe,
    onLongPress: _onLongPress,
    onTap: () {
      setState(() {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => dishesList(type: type, title: label),
          ),
        );
      });
    },
    swipeConfig: const SimpleSwipeConfig(
      verticalThreshold: 40.0,
      horizontalThreshold: 40.0,
      swipeDetectionBehavior: SwipeDetectionBehavior.continuousDistinct,
    ),
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: color, width: 2.0),
      ),
      child: SizedBox(
        width: cardWidth,  // Responsive card width
        height: cardHeight, // Responsive card height
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(icon, size: cardWidth * 0.5), // Adjust icon size to fit card
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Container(
                height: cardHeight * 0.25,  // Responsive label container height
                width: cardWidth,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15.0),
                    bottomRight: Radius.circular(15.0),
                  ),
                  child: Container(
                    color: color,
                    padding: const EdgeInsets.all(6.0),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    ),
  );
}
}

class EditableCategoryCard extends StatefulWidget {
  final IconData initialIcon;
  final Color color;
  final String initialLabel;
  final String type;
  final Future<void> Function(String textFromUser, String type) onAddLink;

  const EditableCategoryCard({
    required this.initialIcon,
    required this.color,
    required this.initialLabel,
    required this.type,
    required this.onAddLink, // Add this callback
    Key? key,
  }) : super(key: key);

  @override
  _EditableCategoryCardState createState() => _EditableCategoryCardState();
}

class _EditableCategoryCardState extends State<EditableCategoryCard> {
  late IconData _currentIcon;
  late String _currentLabel;
  late TextEditingController _labelController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _currentIcon = widget.initialIcon;
    _currentLabel = widget.initialLabel;
    _labelController = TextEditingController(text: _currentLabel);
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _editText() {
    setState(() {
      _isEditing = true;
    });
  }

  void _saveText() {
    setState(() {
      _currentLabel = _labelController.text;
      _isEditing = false;
    });
  }

Future<void> _chooseIcon() async {
  IconData? selectedIcon = await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Select an Icon'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.maxFinite,
              child: Wrap(
                spacing: 8.0, // Horizontal spacing between icons
                runSpacing: 8.0, // Vertical spacing between rows
                children: [
                  FontAwesomeIcons.apple,
                  FontAwesomeIcons.bowlRice,
                  FontAwesomeIcons.bowlFood,
                  FontAwesomeIcons.plateWheat,
                  FontAwesomeIcons.bacon,
                  FontAwesomeIcons.breadSlice,
                  FontAwesomeIcons.coffee,
                  FontAwesomeIcons.cocktail,
                  FontAwesomeIcons.cookie,
                  FontAwesomeIcons.cutlery,
                  FontAwesomeIcons.drumstickBite,
                  FontAwesomeIcons.fish,
                  FontAwesomeIcons.hamburger,
                  FontAwesomeIcons.hotdog,
                  FontAwesomeIcons.hotjar,
                  FontAwesomeIcons.iceCream,
                  FontAwesomeIcons.lemon,
                  FontAwesomeIcons.martiniGlass,
                  FontAwesomeIcons.mugHot,
                  FontAwesomeIcons.pizzaSlice,
                  FontAwesomeIcons.utensils,
                  FontAwesomeIcons.wineBottle,
                  Ionicons.fast_food,
                  Ionicons.fast_food_outline,
                  Ionicons.fast_food_sharp,
                  Ionicons.pizza,
                  Ionicons.pizza_outline,
                  Ionicons.pizza_sharp,
                  Ionicons.cafe,
                  Ionicons.cafe_outline,
                  Ionicons.cafe_sharp,
                  Ionicons.beer,
                  Ionicons.beer_outline,
                  Ionicons.beer_sharp,
                  Ionicons.wine,
                  Ionicons.wine_outline,
                  Ionicons.wine_sharp,
                  Ionicons.ice_cream,
                  Ionicons.ice_cream_outline,
                  Ionicons.ice_cream_sharp,
                  FrinoIcons.f_cocktail,
                  FrinoIcons.f_cook,
                  FrinoIcons.f_mug,
                  FrinoIcons.f_palm,
                  FrinoIcons.f_pot_flower,
                  FrinoIcons.f_piggy_bank__1_,
                  FrinoIcons.f_meat,
                  Icons.fastfood,
                  Icons.restaurant,
                  Icons.local_restaurant,
                  Icons.coffee,
                  Icons.local_pizza,
                  Icons.local_bar,
                  Icons.local_cafe,
                  Icons.local_offer,
                ]
                    .map(
                      (icon) => IconButton(
                        icon: Icon(icon),
                        onPressed: () {
                          Navigator.of(context).pop(icon);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            SizedBox(height: 8.0), // Space between icons and close button
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      );
    },
  );

  if (selectedIcon != null) {
    setState(() {
      _currentIcon = selectedIcon;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions using MediaQuery
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final fontSize= MediaQuery.of(context).size.height * 0.017;

    // Adjust the size based on screen width
    final double cardWidth = screenWidth * 0.23;
    final double cardHeight = screenHeight * 0.13;
    final double iconSize = cardWidth * 0.5;

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onLongPress: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                TextEditingController _dialogTextController =
                    TextEditingController(text: _currentLabel);

                return AlertDialog(
                  title: const Text("Edit Icon or Text"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _dialogTextController,
                        decoration: const InputDecoration(
                          labelText: "Edit Text",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _chooseIcon, // Call the method to choose an icon
                        child: const Text("Choose Icon"),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _currentLabel = _dialogTextController.text;
                        });
                        widget.onAddLink(_currentLabel, widget.type).then((_) {
                          // Optional: handle post-add actions if needed
                        });
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Text("Save"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog without saving
                      },
                      child: const Text("Cancel"),
                    ),
                  ],
                );
              },
            );
          },
          onDoubleTap: _editText,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    dishesList(type: widget.type, title: _currentLabel),
              ),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: widget.color, width: 2.0),
            ),
            child: SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _isEditing
                      ? IconButton(
                          icon: Icon(_currentIcon, size: iconSize),
                          onPressed: _chooseIcon,
                        )
                      : Icon(_currentIcon, size: iconSize),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Container(
                      height: cardHeight*0.3,
                      width: cardWidth,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(15.0),
                          bottomRight: Radius.circular(15.0),
                        ),
                        child: Container(
                          color: widget.color,
                          padding: const EdgeInsets.all(6.0),
                          child: _isEditing
                              ? TextField(
                                  controller: _labelController,
                                  onSubmitted: (_) => _saveText(),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10.0),
                                  ),
                                )
                              : Text(
                                  _currentLabel,
                                  style:  TextStyle(
                                      fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


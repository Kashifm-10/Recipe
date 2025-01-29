import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frino_icons/frino_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:recipe/collections/dishes.dart';
import 'package:recipe/models/br_database.dart';
import 'package:recipe/pages/biggerScreens/allDishes.dart';
import 'package:recipe/pages/biggerScreens/dishesPage.dart';
import 'package:recipe/pages/profilePage.dart';
import 'package:recipe/pages/biggerScreens/recipePage.dart';
import 'package:recipe/pages/smallScreens/s_allDishes.dart';
import 'package:recipe/pages/smallScreens/s_dishesPage.dart';
import 'package:recipe/pages/smallScreens/s_recipePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart' as color_picker;
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart'
    as hsv_picker;
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class CategoryService {
  // Fetch categories from the 'categories' table in Supabase
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final response = await Supabase.instance.client
        .from('titles') // Table name in Supabase
        .select('*');

    List<Map<String, dynamic>> categories = [];
    for (var item in response) {
      Color categoryColor =
          await _getColorFromType(item['type']); // Await here to get the color
      categories.add({
        'label': item['title'] ?? '',
        'type': item['type'] ?? '',
        'icon': _getIconFromString(item['icon'] ?? ''),
        'color': categoryColor, // Use the fetched color
      });
    }

    return categories;
  }

  // Helper function to map icon string to corresponding Flutter IconData
  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'apple':
        return FontAwesomeIcons.apple;
      case 'bowl_rice':
        return FontAwesomeIcons.bowlRice;
      case 'bowl_food':
        return FontAwesomeIcons.bowlFood;
      case 'plate_wheat':
        return FontAwesomeIcons.plateWheat;
      case 'bacon':
        return FontAwesomeIcons.bacon;
      case 'bread_slice':
        return FontAwesomeIcons.breadSlice;
      case 'coffee':
        return FontAwesomeIcons.coffee;
      case 'cocktail':
        return FontAwesomeIcons.cocktail;
      case 'cookie':
        return FontAwesomeIcons.cookie;
      case 'cutlery':
        return FontAwesomeIcons.cutlery;
      case 'drumstick_bite':
        return FontAwesomeIcons.drumstickBite;
      case 'fish':
        return FontAwesomeIcons.fish;
      case 'hamburger':
        return FontAwesomeIcons.hamburger;
      case 'hotdog':
        return FontAwesomeIcons.hotdog;
      case 'hotjar':
        return FontAwesomeIcons.hotjar;
      case 'ice_cream':
        return FontAwesomeIcons.iceCream;
      case 'lemon':
        return FontAwesomeIcons.lemon;
      case 'martini_glass':
        return FontAwesomeIcons.martiniGlass;
      case 'mug_hot':
        return FontAwesomeIcons.mugHot;
      case 'pizza_slice':
        return FontAwesomeIcons.pizzaSlice;
      case 'utensils':
        return FontAwesomeIcons.utensils;
      case 'wine_bottle':
        return FontAwesomeIcons.wineBottle;
      case 'fast_food':
        return Ionicons.fast_food;
      case 'fast_food_outline':
        return Ionicons.fast_food_outline;
      case 'fast_food_sharp':
        return Ionicons.fast_food_sharp;
      case 'pizza':
        return Ionicons.pizza;
      case 'pizza_outline':
        return Ionicons.pizza_outline;
      case 'pizza_sharp':
        return Ionicons.pizza_sharp;
      case 'cafe':
        return Ionicons.cafe;
      case 'cafe_outline':
        return Ionicons.cafe_outline;
      case 'cafe_sharp':
        return Ionicons.cafe_sharp;
      case 'beer':
        return Ionicons.beer;
      case 'beer_outline':
        return Ionicons.beer_outline;
      case 'beer_sharp':
        return Ionicons.beer_sharp;
      case 'wine':
        return Ionicons.wine;
      case 'wine_outline':
        return Ionicons.wine_outline;
      case 'wine_sharp':
        return Ionicons.wine_sharp;
      case 'ice_cream':
        return Ionicons.ice_cream;
      case 'ice_cream_outline':
        return Ionicons.ice_cream_outline;
      case 'ice_cream_sharp':
        return Ionicons.ice_cream_sharp;
      case 'f_cocktail':
        return FrinoIcons.f_cocktail;
      case 'f_cook':
        return FrinoIcons.f_cook;
      case 'f_mug':
        return FrinoIcons.f_mug;
      case 'f_palm':
        return FrinoIcons.f_palm;
      case 'f_pot_flower':
        return FrinoIcons.f_pot_flower;
      case 'f_piggy_bank':
        return FrinoIcons.f_piggy_bank__1_;
      case 'f_meat':
        return FrinoIcons.f_meat;
      case 'fastfood':
        return Icons.fastfood;
      case 'restaurant':
        return Icons.restaurant;
      case 'local_restaurant':
        return Icons.local_restaurant;
      case 'coffee':
        return Icons.coffee;
      case 'local_pizza':
        return Icons.local_pizza;
      case 'local_bar':
        return Icons.local_bar;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'local_offer':
        return Icons.local_offer;
      default:
        return Icons
            .restaurant_menu_outlined; // Default icon if no match is found
    }
  }

  Future<List<Color>> fetchColors() async {
    final response = await Supabase.instance.client
        .from(
            'titles') // Replace 'titles' with the correct table name in your database
        .select(
            'color, type'); // Fetch both color and type fields (or any field for sorting)

    final data = List<Map<String, dynamic>>.from(response);

    // Sort data by 'type' after converting 'type' to int
    data.sort((a, b) => int.parse(a['type']).compareTo(int.parse(b['type'])));

    // Convert sorted data to a list of colors
    List<Color> colors = data.map((item) {
      return _colorFromHex(item['color']);
    }).toList();
    //List<Color> colors = [];
    return colors;
  }

  Color _colorFromHex(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  Future<Color> _getColorFromType(String type) async {
    List<Color> colors = await fetchColors();

    switch (type) {
      case '1':
        return colors.isNotEmpty
            ? colors[0]
            : const Color.fromARGB(255, 238, 183, 125);
      case '2':
        return colors.isNotEmpty
            ? colors[1]
            : const Color.fromARGB(255, 245, 226, 119);
      case '3':
        return colors.isNotEmpty
            ? colors[2]
            : const Color.fromARGB(255, 245, 145, 197);
      case '4':
        return colors.isNotEmpty
            ? colors[3]
            : const Color.fromARGB(255, 242, 203, 160);
      case '5':
        return colors.isNotEmpty
            ? colors[4]
            : const Color.fromARGB(255, 217, 212, 182);
      case '6':
        return colors.isNotEmpty
            ? colors[5]
            : const Color.fromARGB(255, 240, 184, 213);
      case '7':
        return colors.isNotEmpty
            ? colors[6]
            : const Color.fromARGB(255, 242, 203, 160);
      case '8':
        return colors.isNotEmpty
            ? colors[7]
            : const Color.fromARGB(255, 217, 212, 182);
      case '9':
        return colors.isNotEmpty
            ? colors[8]
            : const Color.fromARGB(255, 240, 184, 213);
      case '10':
        return colors.isNotEmpty
            ? colors[9]
            : const Color.fromARGB(255, 242, 203, 160);
      case '11':
        return colors.isNotEmpty
            ? colors[10]
            : const Color.fromARGB(255, 217, 212, 182);
      case '12':
        return colors.isNotEmpty
            ? colors[11]
            : const Color.fromARGB(255, 240, 184, 213);
      default:
        return Colors.grey;
    }
  }
}

class MySmallHomePage extends StatefulWidget {
  const MySmallHomePage({super.key});

  @override
  State<MySmallHomePage> createState() => _MySmallHomePageState();
}

class _MySmallHomePageState extends State<MySmallHomePage> {
  late Future<List<Map<String, dynamic>>> _categories;
  List<Dish> searchdishes = [];
  List<Dish> allDishes = [];
  List<int> typeCountList = [];
  List<Map<String, int>> typeCategoryCountList = [];
  List<Dish> searchNames = [];
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isLoading = true; // Manage loading state
  TextEditingController textController = TextEditingController();
  String searchQuery = '';
  bool _isErrorDialogShown = false;
  final FocusNode _focusNode = FocusNode();

/*   List<Color> colorList = [
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
  ]; */
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
  List<String> homeIcons = [
    'assets/icons/breakfast.png',
    'assets/icons/lunch.png',
    'assets/icons/dinner.png',
    'assets/icons/gravy.png',
    'assets/icons/sweets.png',
    'assets/icons/starters.png',
    'assets/icons/snacks.png',
    'assets/icons/beverages.png',
    'assets/icons/salads.png',
    'assets/icons/others.png',
  ];
  @override
  void initState() {
    super.initState();
    countDishes();
    fetchDishes();

    // Initialize _categories with a fetch request immediately
    _categories = CategoryService().fetchCategories();
  }

  /*  void addTitle(String title, String type) {
    context.read<database>().addTitle(title, type);
    _categories = CategoryService()
        .fetchCategories(); // Refresh the categories after adding a title
  } */
  Future<void> fetchDishes() async {
    try {
      final response = await Supabase.instance.client.from('dishes').select();
      final data = List<Map<String, dynamic>>.from(response);

      setState(() {
        searchdishes = data
            .map((item) => Dish(
                  name: item['name'],
                  serial: item['serial'],
                  type: item['type'],
                  duration: item['duration'],
                  category: item['category'],
                  date: item['date'],
                  time: item['time'],
                ))
            .toList();
      });
    } catch (e) {
      print("Error fetching dishes: $e");
    }
  }

  Future<void> countDishes() async {
    final prefs = await SharedPreferences.getInstance();
    String? access = prefs.getString('access');
    String? mail = prefs.getString('email');
    try {
      final response = access == 'false'
          ? await Supabase.instance.client
              .from('dishes')
              .select()
              .eq('mail', mail!)
          : await Supabase.instance.client.from('dishes').select();
      final data = List<Map<String, dynamic>>.from(response);

      // Parse dishes
      List<Dish> dishes = data
          .map((item) => Dish(
                name: item['name'],
                serial: item['serial'],
                type: item['type'],
                duration: item['duration'],
                category: item['category'],
                date: item['date'],
                time: item['time'],
              ))
          .toList();

      // Filter by type and category
      List<Map<String, int>> typeCategoryCounts =
          List.generate(10, (typeIndex) {
        int category0Count = dishes
            .where((dish) =>
                dish.type == '${typeIndex + 1}' && dish.category == "0")
            .length;
        int category1Count = dishes
            .where((dish) =>
                dish.type == '${typeIndex + 1}' && dish.category == "1")
            .length;
        return {
          'type': typeIndex + 1,
          'category0': category0Count,
          'category1': category1Count,
        };
      });
      for (var count in typeCategoryCounts) {
        print(
            'Type ${count['type']}: Category 0 Count = ${count['category0']}, Category 1 Count = ${count['category1']}');
      }

      setState(() {
        allDishes = dishes;
        typeCategoryCountList = typeCategoryCounts; // Store counts in a list
      });
    } catch (e) {
      print("Error fetching dishes: $e");
    }
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
              textController.text = searchQuery; // Update TextField
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

  @override
  Widget build(BuildContext context) {
    Color allColor = Colors.teal;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    bool _isEditing = false;
    String _currentLabel = "Find By Ingredients"; // Default label
    const Color _cardColor =
        Color.fromARGB(255, 128, 194, 233); // Default color
    const IconData cardIcon = HeroiconsOutline.archiveBox; // Default icon
    final double cardWidth = screenWidth * 0.05;
    final double cardHeight = screenHeight * 0.08;
    final double iconSize = screenWidth * 0.07;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        // When tapping anywhere outside the search bar, it unfocuses the search field and hides the keyboard.
        onTap: () {
          countDishes();
          fetchDishes();
          FocusScope.of(context).unfocus();
          textController.clear();
          _focusNode.unfocus();
        },
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/images/bg_home.jpg', // Image for smaller screens
                width: screenWidth,
                height: screenHeight,
                fit: BoxFit.cover,
              ),
            ),
            // Profile Icon
            Positioned(
              top: 30,
              right: 20,
              child: IconButton(
                icon: const Icon(
                  HeroiconsSolid.user,
                  size: 30,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePage()),
                  );
                },
              ),
            ),
            // Main Content
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _categories,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: Lottie.asset(
                    'assets/lottie_json/burger.json',
                    width: screenWidth * 0.6,
                  ));
                } else if (snapshot.hasError) {
                  if (!_isErrorDialogShown) {
                    _isErrorDialogShown = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: Container(
                              height: screenHeight * 0.15,
                              width: screenWidth * 0.4,
                              child: Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.wifi_off_rounded, size: 50),
                                  Text(
                                    "No Connection",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Text('Please Connect to Internet'),
                                  TextButton(
                                    onPressed: () {
                                      _isErrorDialogShown =
                                          false; // Reset dialog state

                                      Navigator.of(context).pop();
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const MySmallHomePage()),
                                        (Route<dynamic> route) => false,
                                      );
                                    },
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ))),
                        ),
                      );
                    });
                  }
                  return const Center(child: Text(''));
                } else {
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.07),
                    child: Column(
                      children: [
                        // Title
                        Padding(
                            padding: EdgeInsets.only(top: 0.0),
                            child: Image.asset(
                              'assets/images/banner.png',
                              width: screenWidth * 0.4,
                            )),
                        SizedBox(
                          height: screenHeight * 0.03,
                        ),
                        // Search Bar
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.09),
                          child: DropDownSearchField(
                            displayAllSuggestionWhenTap: true,
                            textFieldConfiguration: TextFieldConfiguration(
                              controller: textController,
                              focusNode: _focusNode, // Attach the focus node
                              autofocus: false,
                              style:
                                  DefaultTextStyle.of(context).style.copyWith(
                                        fontStyle: FontStyle.normal,
                                      ),
                              decoration: InputDecoration(
                                hintText: "Search Dishes",
                                hintStyle: GoogleFonts.poppins(
                                  color: Colors
                                      .grey, // Change to your preferred color
                                ),
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: Stack(
                                  alignment: Alignment.centerRight,
                                  children: [
                                    Positioned(
                                      right: 3.0,
                                      child: IconButton(
                                        icon: const Icon(
                                          Ionicons.close_circle_outline,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          // Clear the search field and close dropdown
                                          textController.clear();
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          right: screenWidth * 0.08,
                                          top: screenHeight * 0.002),
                                      child: _focusNode.hasFocus
                                          ? IconButton(
                                              onPressed: !_isListening
                                                  ? _startListening
                                                  : _stopListening,
                                              icon: Icon(
                                                _isListening
                                                    ? Icons.mic
                                                    : Icons.mic_none,
                                                color: _isListening
                                                    ? Colors.red
                                                    : Colors.grey,
                                              ),
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            suggestionsCallback: (pattern) async {
                              await fetchDishes();
                              final lowercasePattern = pattern.toLowerCase();
                              return searchdishes
                                  .where((dish) => dish.name
                                      .toLowerCase()
                                      .contains(lowercasePattern))
                                  .toList();
                            },
                            itemBuilder: (context, suggestion) {
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 5.0, left: 10.0, right: 10.0),
                                    child: ListTile(
                                      leading: /* const Icon(Icons.fastfood,
                                          color: Colors.orange, size: 30), */
                                          Padding(
                                        padding:
                                            EdgeInsets.all(screenWidth * 0.0),
                                        child: Image.asset(homeIcons[
                                            int.parse(suggestion.type!) - 1]),
                                      ),
                                      title: Text(
                                        suggestion.name,
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      subtitle: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              suggestion.duration != null
                                                  ? (() {
                                                      double duration = double
                                                              .tryParse(suggestion
                                                                  .duration!) ??
                                                          0.0;
                                                      int hours =
                                                          duration.toInt();
                                                      int minutes =
                                                          ((duration - hours) *
                                                                  60)
                                                              .toInt();

                                                      if (hours > 0 &&
                                                          minutes > 0) {
                                                        return '$hours hr ${minutes} min';
                                                      } else if (hours > 0) {
                                                        return '$hours hr';
                                                      } else if (minutes > 0) {
                                                        return '$minutes min';
                                                      } else {
                                                        return '0 min';
                                                      }
                                                    }())
                                                  : 'Invalid duration',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        ],
                                      ),
                                      tileColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: const BorderSide(
                                            color: Colors.transparent),
                                      ),
                                      trailing: CircleAvatar(
                                        radius: 10,
                                        backgroundColor:
                                            Colors.white.withOpacity(0.0),
                                        child: suggestion.category == "1"
                                            ? const Icon(Icons.circle_rounded,
                                                color: Colors.red, size: 15)
                                            : const Icon(Icons.circle_rounded,
                                                color: Colors.green, size: 15),
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    color: Colors.grey,
                                    height: 1,
                                    thickness: 0.4,
                                    indent:
                                        MediaQuery.of(context).size.width * 0.1,
                                    endIndent:
                                        MediaQuery.of(context).size.width * 0.1,
                                  ),
                                ],
                              );
                            },
                            onSuggestionSelected: (suggestion) {
                              setState(() {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => smallrecipe(
                                          serial: suggestion.serial,
                                          type: suggestion.type,
                                          dish: suggestion.name,
                                          category: suggestion.category,
                                          access: true,
                                          imageURL: suggestion.imageUrl ?? ' ',
                                          background: colorList[
                                              int.parse(suggestion.type!) - 1],
                                        )));
                              });
                              print("suggestion: ${suggestion.name}");
                            },
                            suggestionsBoxDecoration: SuggestionsBoxDecoration(
                              elevation: 0,
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            noItemsFoundBuilder: (context) => Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Lottie.asset(
                                    'assets/lottie_json/nothing.json',
                                    width: screenWidth * 0.9,
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    "Nothing Here",
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Adjust the spacing
                        // Replace Expanded with Container or SizedBox with a max height
                        SizedBox(
                          height: screenHeight *
                              0.60, // Set the maximum height (adjust as needed)
                          child: ListView(
                            physics:
                                const ScrollPhysics(), //remove this line to make scrollable
                            padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.01,
                                horizontal: screenWidth * 0.06),
                            children: [
                              // Categories from Snapshot
                              ..._buildCategoryRows(snapshot.data ?? []),
                              // Your first GestureDetector Card
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.02,
                                    vertical: screenHeight * 0.004),
                                child: Card(
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        PageTransition(
                                          curve: Curves.linear,
                                          type: PageTransitionType.bottomToTop,
                                          duration: const Duration(
                                              milliseconds:
                                                  300), // Adjust duration to slow down the transition
                                          child: MediaQuery.of(context)
                                                      .size
                                                      .width >
                                                  600
                                              ? alldishesList(
                                                  title: _currentLabel,
                                                  scafColor: allColor,
                                                )
                                              : smallalldishesList(
                                                  title: _currentLabel,
                                                  scafColor: allColor,
                                                ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: cardWidth,
                                      height: cardHeight,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [allColor, allColor],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: cardWidth * 3),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(0.0),
                                              child: Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.05,
                                                width: 60,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                ),
                                                child: /* Icon(
                                                  cardIcon,
                                                  size: iconSize,
                                                  color: Colors.teal.shade600,
                                                ), */
                                                    Padding(
                                                  padding: EdgeInsets.all(
                                                      screenWidth * 0.01),
                                                  child: Image.asset(
                                                      'assets/icons/ingredients.png'),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _currentLabel,
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.04,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    /* const Text(
                                                        "Subtitle or Description",
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 14,
                                                          color: Colors.white70,
                                                        ),
                                                      ), */
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /*  List<Widget> _buildCategoryRows(List<Map<String, dynamic>> categories) {
    // Sort categories by 'type' after converting 'type' to int
    categories
        .sort((a, b) => int.parse(a['type']).compareTo(int.parse(b['type'])));

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
            vertical: MediaQuery.of(context).size.height * 0.0,
            horizontal: MediaQuery.of(context).size.width *
                0.01, // Make horizontal padding responsive
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: rowCategories.map((category) {
              // Directly pass the Color object for color
              return Row(
                children: [
                  const SizedBox(width: 6),
                  EditableCategoryCard(
                    initialIcon: category['icon'],
                    color: category['color'], // Pass Color object directly
                    initialLabel: category['label'],
                    type: category['type'],
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      );
    }

    return rows;
  } */
  List<Widget> _buildCategoryRows(List<Map<String, dynamic>> categories) {
    // Sort categories by 'type' after converting 'type' to int
    categories
        .sort((a, b) => int.parse(a['type']).compareTo(int.parse(b['type'])));

    final List<Widget> rows = [];
    for (int i = 0; i < categories.length; i += 2) {
      rows.add(
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.004,
            horizontal:
                MediaQuery.of(context).size.width * 0.02, // Responsive padding
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // First card
              Expanded(
                child: EditableCategoryCard(
                  initialIcon: categories[i]['icon'],
                  color: colorList[i], // Pass Color object directly
                  initialLabel: categories[i]['label'],
                  type: categories[i]['type'],
                  veg: typeCategoryCountList[i]['category0']!,
                  non_veg: typeCategoryCountList[i]['category1']!,
                  homeIcons: homeIcons[i],
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              // Second card if available
              if (i + 1 < categories.length)
                Expanded(
                  child: EditableCategoryCard(
                    initialIcon: categories[i + 1]['icon'],
                    color: colorList[i +
                        1] /* categories[i + 1]
                        ['color'] */
                    , // Pass Color object directly
                    initialLabel: categories[i + 1]['label'],
                    type: categories[i + 1]['type'],
                    veg: typeCategoryCountList[i + 1]['category0']!,
                    non_veg: typeCategoryCountList[i + 1]['category1']!,
                    homeIcons: homeIcons[i + 1],
                  ),
                )
              else
                const Expanded(
                    child: SizedBox()), // Empty space if no second card
            ],
          ),
        ),
      );
    }
    return rows;
  }
}

class EditableCategoryCard extends StatefulWidget {
  final IconData initialIcon;
  Color color; // Make color non-final so it can be updated dynamically
  final String initialLabel;
  final String type;
  final int veg;
  final int non_veg;
  final String homeIcons;

  EditableCategoryCard({
    required this.initialIcon,
    required this.color,
    required this.initialLabel,
    required this.type,
    required this.veg,
    required this.non_veg,
    required this.homeIcons,
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
          title: Text(
            'Select an Icon',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.maxFinite,
                child: Wrap(
                  spacing: 8.0, // Horizontal spacing between icons
                  runSpacing: 8.0, // Vertical spacing between rows
                  children: [
                    // FontAwesome
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
                    FontAwesomeIcons.iceCream,
                    FontAwesomeIcons.lemon,
                    FontAwesomeIcons.martiniGlass,
                    FontAwesomeIcons.mugHot,
                    FontAwesomeIcons.pizzaSlice,
                    FontAwesomeIcons.utensils,
                    FontAwesomeIcons.wineBottle,

                    // Ionicons
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

                    // FrinoIcons
                    FrinoIcons.f_cocktail,
                    FrinoIcons.f_cook,
                    FrinoIcons.f_mug,
                    FrinoIcons.f_palm,
                    FrinoIcons.f_pot_flower,
                    FrinoIcons.f_piggy_bank__1_,
                    FrinoIcons.f_meat,

                    // Material Icons
                    Icons.fastfood,
                    Icons.restaurant,
                    Icons.local_restaurant,
                    Icons.coffee,
                    Icons.local_pizza,
                    Icons.local_bar,
                    Icons.local_cafe,
                    Icons.local_offer,

                    // Additional Food Outlined Icons
                    // Bowls and Food Items
                    FontAwesomeIcons.bowlRice, // Rice bowl icon
                    FontAwesomeIcons.bowlFood, // General bowl icon

                    FontAwesomeIcons.champagneGlasses, // Champagne glass
                    FontAwesomeIcons.egg, // Egg food icon
                    FontAwesomeIcons.fish, // Fish icon
                    FontAwesomeIcons.cheese, // Cheese icon
                    FontAwesomeIcons.hamburger, // Hamburger icon
                    FontAwesomeIcons.pizzaSlice, // Doughnut icon
                    FontAwesomeIcons.mugHot, // Hot mug icon
                    FontAwesomeIcons.iceCream, // Ice cream icon
                    FontAwesomeIcons.cocktail, // Cocktail bowl
                    FontAwesomeIcons.cookie, // Cookie icon
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
              const SizedBox(
                  height: 8.0), // Space between icons and close button
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Close',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Color(0xFFFE9A8B), // Peach color
                    ),
                  ),
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

      // Update the icon in Supabase
      await _updateIconInSupabase(selectedIcon);
    }
  }

  Future<void> _updateIconInSupabase(IconData selectedIcon) async {
    String iconName =
        _getIconNameFromIconData(selectedIcon); // Convert IconData to string

    try {
      // Update the icon in Supabase database
      final response = await Supabase.instance.client
          .from('titles') // Table in Supabase
          .update({'icon': iconName}) // Update the 'icon' field
          .eq('type', widget.type);

      if (response.error != null) {
        // Handle error (optional)
        print('Error updating icon: ${response.error!.message}');
      } else {
        print('Icon updated successfully');
      }
    } catch (e) {
      print('Error updating icon: $e');
    }
  }

  String _getIconNameFromIconData(IconData icon) {
    // Manually mapping IconData to string for Supabase
    if (icon == FontAwesomeIcons.apple) return 'apple';
    if (icon == FontAwesomeIcons.bowlRice) return 'bowl_rice';
    if (icon == FontAwesomeIcons.bowlFood) return 'bowl_food';
    if (icon == FontAwesomeIcons.plateWheat) return 'plate_wheat';
    if (icon == FontAwesomeIcons.bacon) return 'bacon';
    if (icon == FontAwesomeIcons.breadSlice) return 'bread_slice';
    if (icon == FontAwesomeIcons.coffee) return 'coffee';
    if (icon == FontAwesomeIcons.cocktail) return 'cocktail';
    if (icon == FontAwesomeIcons.cookie) return 'cookie';
    if (icon == FontAwesomeIcons.cutlery) return 'cutlery';
    if (icon == FontAwesomeIcons.drumstickBite) return 'drumstick_bite';
    if (icon == FontAwesomeIcons.fish) return 'fish';
    if (icon == FontAwesomeIcons.hamburger) return 'hamburger';
    if (icon == FontAwesomeIcons.hotdog) return 'hotdog';
    if (icon == FontAwesomeIcons.hotjar) return 'hotjar';
    if (icon == FontAwesomeIcons.iceCream) return 'ice_cream';
    if (icon == FontAwesomeIcons.lemon) return 'lemon';
    if (icon == FontAwesomeIcons.martiniGlass) return 'martini_glass';
    if (icon == FontAwesomeIcons.mugHot) return 'mug_hot';
    if (icon == FontAwesomeIcons.pizzaSlice) return 'pizza_slice';
    if (icon == FontAwesomeIcons.utensils) return 'utensils';
    if (icon == FontAwesomeIcons.wineBottle) return 'wine_bottle';
    if (icon == Ionicons.fast_food) return 'fast_food';
    if (icon == Ionicons.fast_food_outline) return 'fast_food_outline';
    if (icon == Ionicons.fast_food_sharp) return 'fast_food_sharp';
    if (icon == Ionicons.pizza) return 'pizza';
    if (icon == Ionicons.pizza_outline) return 'pizza_outline';
    if (icon == Ionicons.pizza_sharp) return 'pizza_sharp';
    if (icon == Ionicons.cafe) return 'cafe';
    if (icon == Ionicons.cafe_outline) return 'cafe_outline';
    if (icon == Ionicons.cafe_sharp) return 'cafe_sharp';
    if (icon == Ionicons.beer) return 'beer';
    if (icon == Ionicons.beer_outline) return 'beer_outline';
    if (icon == Ionicons.beer_sharp) return 'beer_sharp';
    if (icon == Ionicons.wine) return 'wine';
    if (icon == Ionicons.wine_outline) return 'wine_outline';
    if (icon == Ionicons.wine_sharp) return 'wine_sharp';
    if (icon == Ionicons.ice_cream) return 'ice_cream';
    if (icon == Ionicons.ice_cream_outline) return 'ice_cream_outline';
    if (icon == Ionicons.ice_cream_sharp) return 'ice_cream_sharp';
    if (icon == FrinoIcons.f_cocktail) return 'f_cocktail';
    if (icon == FrinoIcons.f_cook) return 'f_cook';
    if (icon == FrinoIcons.f_mug) return 'f_mug';
    if (icon == FrinoIcons.f_palm) return 'f_palm';
    if (icon == FrinoIcons.f_pot_flower) return 'f_pot_flower';
    if (icon == FrinoIcons.f_piggy_bank__1_) return 'f_piggy_bank';
    if (icon == FrinoIcons.f_meat) return 'f_meat';
    if (icon == Icons.fastfood) return 'fastfood';
    if (icon == Icons.restaurant) return 'restaurant';
    if (icon == Icons.local_restaurant) return 'local_restaurant';
    if (icon == Icons.coffee) return 'coffee';
    if (icon == Icons.local_pizza) return 'local_pizza';
    if (icon == Icons.local_bar) return 'local_bar';
    if (icon == Icons.local_cafe) return 'local_cafe';
    if (icon == Icons.local_offer) return 'local_offer';

    // Additional icons for bowls, plates, and more
    if (icon == FontAwesomeIcons.cheese) return 'cheese';

    // Default value if no match found
    return 'category';
  }

  // New method to choose a color
  Future<void> _chooseColor() async {
    Color? selectedColor = await showDialog(
      context: context,
      builder: (context) {
        Color tempColor = Color(widget.color.value);
        return AlertDialog(
          title: Text(
            'Select a Color',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          content: SizedBox(
            width: 500, // Specify a width
            height: 500,
            child: SingleChildScrollView(
              child: hsv_picker.ColorPicker(
                // Use prefixed alias here
                color: tempColor,
                onChanged: (value) {
                  tempColor = value; // Store the selected color temporarily
                },
                initialPicker:
                    hsv_picker.Picker.paletteHue, // Use prefixed alias here
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(tempColor); // Return the selected color
              },
              child: Text(
                'Select',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Color(0xFFFE9A8B), // Peach color
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss without selecting
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Color(0xFFFE9A8B), // Peach color
                ),
              ),
            ),
          ],
        );
      },
    );

    if (selectedColor != null) {
      setState(() {
        widget.color = selectedColor; // Convert color to hex string
      });

      // Update the color in Supabase
      await _updateColorInSupabase(widget.color);
    }
  }

  Future<void> _updateColorInSupabase(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    String? mail = prefs.getString('email');
    String iconName = _getIconNameFromIconData(_currentIcon);
    // Check if an entry with the specified type and mail exists
    final existingRecord = await Supabase.instance.client
        .from('titles')
        .select()
        .eq('type', widget.type)
        //.eq('mail', mail!)
        .maybeSingle();

    if (existingRecord != null) {
      // If it exists, update the color
      final response = await Supabase.instance.client.from('titles').update({
        'color':
            '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase().substring(2)}'
      }).eq('type', widget.type);
      //.eq('mail', mail);
    } else {
      // If it doesn't exist, insert a new record
      final response = await Supabase.instance.client.from('titles').insert({
        'title': widget.initialLabel,
        'icon': iconName,
        'type': widget.type,
        'mail': mail,
        'color':
            '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase().substring(2)}'
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
            //to edit color and icon
            /* onLongPress: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  TextEditingController dialogTextController =
                      TextEditingController(text: _currentLabel);

                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Center(
                      child: Text(
                        "Edit Icon or Text",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    content: SizedBox(
                      width: 400, // Increase the width of the dialog
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: dialogTextController,
                            decoration: InputDecoration(
                              labelText: "Edit Text",
                              labelStyle: GoogleFonts.poppins(color: Colors.grey[700]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey[400]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.blueAccent),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 12),
                            ),
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _chooseIcon,
                                  icon: const Icon(Icons.edit,
                                      color: Colors.white),
                                  label: const Text("Choose Icon"),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 18, horizontal: 20),
                                    side: const BorderSide(
                                        color:
                                            Color(0xFFFE9A8B)), // Peach color
                                    backgroundColor:
                                        const Color(0xFFFE9A8B), // Peach color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                  width: 10), // Space between the two buttons
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _chooseColor,
                                  icon: const Icon(Icons.color_lens,
                                      color: Colors.white),
                                  label: const Text("Choose Color"),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 18, horizontal: 20),
                                    side: const BorderSide(
                                        color:
                                            Color(0xFFFE9A8B)), // Peach color
                                    backgroundColor:
                                        const Color(0xFFFE9A8B), // Peach color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () async {
                                setState(() {
                                  _currentLabel = dialogTextController.text;
                                });
                                await Supabase.instance.client
                                    .from('titles')
                                    .update({'title': _currentLabel}).eq(
                                        'type', widget.type);
                                CategoryService().fetchCategories();
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                "Save",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Color(0xFFFE9A8B), // Peach color
                                ),
                              ),
                            ),
                            const SizedBox(width: 10), // Space between buttons
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                "Cancel",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Color(0xFFFE9A8B), // Peach color
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            }, */
            onTap: () {
              Navigator.of(context).push(
                PageTransition(
                  curve: Curves.linear,
                  type: PageTransitionType.bottomToTop,
                  duration: const Duration(
                      milliseconds:
                          300), // Adjust duration to slow down the transition
                  child: smalldishesList(
                    type: widget.type,
                    title: _currentLabel,
                  ),
                ),
              );
            },
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8, // Wider width
                height:
                    MediaQuery.of(context).size.height * 0.07, // Shorter height
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(widget.color.value).withOpacity(0.9),
                      Color(widget.color.value).withOpacity(0.9),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(
                  children: [
                    // Icon with circular background
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        height: screenHeight * 0.06,
                        width: screenWidth * 0.08,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        child: /* Icon(
                          _currentIcon,
                          size: screenWidth *
                              0.05, // Adjusted icon size for horizontal layout
                          color: Color(widget.color.value),
                        ), */
                            Padding(
                          padding: EdgeInsets.all(screenWidth * 0.01),
                          child: Image.asset(widget.homeIcons),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title Text
                            _isEditing
                                ? TextField(
                                    controller: _labelController,
                                    onSubmitted: (_) => _saveText(),
                                    decoration: InputDecoration(
                                      hintText: "Enter label...",
                                      hintStyle: GoogleFonts.poppins(
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  )
                                : Text(
                                    _currentLabel,
                                    style: GoogleFonts.poppins(
                                      fontSize: screenWidth * 0.03,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                            const SizedBox(height: 0),
                            // Optional Subtitle or Description
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Veg: ', // Placeholder text
                                          style: GoogleFonts.poppins(
                                            fontSize: screenWidth * 0.02,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          widget.veg
                                              .toString(), // Placeholder text
                                          style: GoogleFonts.poppins(
                                            fontSize: screenWidth * 0.02,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Non-Veg: ', // Placeholder text
                                          style: GoogleFonts.poppins(
                                            fontSize: screenWidth * 0.02,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          widget.non_veg
                                              .toString(), // Placeholder text
                                          style: GoogleFonts.poppins(
                                            fontSize: screenWidth * 0.02,
                                            color:
                                                Colors.white.withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // Spacer at the end
                  ],
                ),
              ),
            ));
      },
    );
  }
}

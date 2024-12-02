import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frino_icons/frino_icons.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:recipe/models/br_database.dart';
import 'package:recipe/pages/all/allDishes.dart';
import 'package:recipe/pages/dishesList.dart';
import 'package:recipe/pages/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart' as color_picker;
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart'
    as hsv_picker;
import 'package:heroicons_flutter/heroicons_flutter.dart';

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
            : const Color.fromARGB(255, 253, 212, 168);
      case '2':
        return colors.isNotEmpty
            ? colors[1]
            : const Color.fromARGB(255, 217, 212, 182);
      case '3':
        return colors.isNotEmpty
            ? colors[2]
            : const Color.fromARGB(255, 240, 184, 213);
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Map<String, dynamic>>> _categories;

  @override
  void initState() {
    super.initState();
    // Initialize _categories with a fetch request immediately
    _categories = CategoryService().fetchCategories();
  }

  /*  void addTitle(String title, String type) {
    context.read<database>().addTitle(title, type);
    _categories = CategoryService()
        .fetchCategories(); // Refresh the categories after adding a title
  } */

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    bool _isEditing = false;
    late TextEditingController _labelController;
    String _currentLabel = "Find By Ingredients"; // Default label
    const Color _cardColor =
        Color.fromARGB(255, 240, 189, 197); // Default color
    const IconData cardIcon = HeroiconsOutline.squaresPlus; // Default icon
    final double cardWidth = MediaQuery.of(context).size.width < 600
        ? screenWidth * 1.5 // Adjusted width for s screens
        : 600; // Default width (600) for l screens

    final double cardHeight = MediaQuery.of(context).size.width < 600
        ? screenWidth * 0.4 // Adjusted height for s screens
        : 170; // Default height for l screens

    final double iconSize = MediaQuery.of(context).size.width < 600
        ? screenWidth * 0.2 // Larger icon size for s screens
        : 80; // Default icon size for l screens

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              MediaQuery.of(context).size.width > 600
                  ? 'assets/images/bg.png' // Image for larger screens
                  : 'assets/images/bg1.png', // Image for smaller screens
              width: screenWidth,
              height: screenHeight,
              fit: BoxFit.cover, // Ensure the background covers the screen
            ),
          ),
          Positioned(
            top: 30, // Adjust the position from the top
            right: 20, // Adjust the position from the right
            child: IconButton(
              icon: const Icon(
                HeroiconsSolid.user,
                size: 30,
                color: Color.fromARGB(255, 238, 160, 160),
              ), // Profile icon
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _categories, // Use the initialized _categories
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.width > 600
                          ? screenHeight * 0.17
                          : screenHeight * 0.18,
                    ), // Dynamically adjust top padding
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ..._buildCategoryRows(snapshot.data ?? []),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => alldishesList(
                                    title: _currentLabel,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 13, right: 13.0, top: 7, bottom: 20),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: const BorderSide(
                                    color: _cardColor,
                                    width: 2.0,
                                  ),
                                ),
                                child: SizedBox(
                                  width: cardWidth,
                                  height: cardHeight,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(cardIcon,
                                          size: iconSize), // Default icon
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 15.0),
                                        child: Container(
                                          height: cardHeight * 0.3,
                                          width: cardWidth,
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                              bottomLeft: Radius.circular(15.0),
                                              bottomRight:
                                                  Radius.circular(15.0),
                                            ),
                                            child: Container(
                                              color: const Color.fromARGB(255, 246, 201, 201),// Light Peach

                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Text(
                                                _currentLabel,
                                                style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.017,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
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
            vertical: MediaQuery.of(context).size.height * 0.01,
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
  }
}

class EditableCategoryCard extends StatefulWidget {
  final IconData initialIcon;
  Color color; // Make color non-final so it can be updated dynamically
  final String initialLabel;
  final String type;

  EditableCategoryCard({
    required this.initialIcon,
    required this.color,
    required this.initialLabel,
    required this.type,
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
          title: const Text(
            'Select an Icon',
            style: TextStyle(
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
                  child: const Text(
                    'Close',
                    style: TextStyle(
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
          title: const Text(
            'Select a Color',
            style: TextStyle(
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
              child: const Text(
                'Select',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFFFE9A8B), // Peach color
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss without selecting
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
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

    final double cardWidth = MediaQuery.of(context).size.width < 600
        ? screenWidth * 0.28 // Adjusted width for larger screens
        : screenWidth * 0.22; // Default width for smaller screens

    final double cardHeight = MediaQuery.of(context).size.width < 600
        ? screenHeight * 0.14 // Adjusted height for larger screens
        : screenHeight * 0.14; // Default height for smaller screens

    final double iconSize = MediaQuery.of(context).size.width < 600
        ? cardWidth * 0.5 // Larger icon size for larger screens
        : cardWidth * 0.5; // Default icon size for smaller screens

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onLongPress: () {
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
                      style: TextStyle(
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
                            labelStyle: TextStyle(color: Colors.grey[700]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[400]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Colors.blueAccent),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 12),
                          ),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _chooseIcon,
                                icon:
                                    const Icon(Icons.edit, color: Colors.white),
                                label: const Text("Choose Icon"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 18, horizontal: 20),
                                  side: const BorderSide(
                                      color: Color(0xFFFE9A8B)), // Peach color
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
                                      color: Color(0xFFFE9A8B)), // Peach color
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
                              style: TextStyle(
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
                              style: TextStyle(
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
          },
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => dishesList(
                  type: widget.type,
                  title: _currentLabel,
                ),
              ),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                  color: Color(widget.color.value),
                  width: 2.0), // Convert hex string back to Color
            ),
            child: SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(_currentIcon, size: iconSize),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: SizedBox(
                      height: cardHeight * 0.3,
                      width: cardWidth,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(15.0),
                          bottomRight: Radius.circular(15.0),
                        ),
                        child: Container(
                          color: Color(
                            (widget.color.value),
                          ), // Convert hex string to color
                          padding: const EdgeInsets.all(9.0),
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
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.height *
                                              0.017,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

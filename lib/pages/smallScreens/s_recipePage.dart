import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar/isar.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:recipe/collections/links.dart';
import 'package:recipe/collections/dishes.dart';
import 'package:recipe/collections/recipe.dart';
import 'package:recipe/models/br_database.dart';
import 'package:recipe/notInUse/brin_db.dart';
import 'package:recipe/collections/ingredients.dart';
import 'package:recipe/list_view/dish_tile.dart';
import 'package:recipe/list_view/ingredientList.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:recipe/models/isar_instance.dart';
import 'package:recipe/list_view/recipeList.dart';
import 'package:linkable/linkable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async'; // For using Timer

class smallrecipe extends StatefulWidget {
  smallrecipe(
      {super.key,
      required this.serial,
      required this.type,
      required this.dish,
      required this.category,
      required this.access,
      required this.background,
      required this.imageURL});
  String? serial;
  String? type;
  String? dish;
  String? category;
  bool? access;
  Color? background;
  String? imageURL;

  @override
  State<smallrecipe> createState() => _smallrecipeState();
}

final isar = IsarInstance().isar;

class _smallrecipeState extends State<smallrecipe>
    with SingleTickerProviderStateMixin {
  //text controller to access what the user typed
  TextEditingController textController = TextEditingController();
  List<Map<String, String>> linkData = [];
  late TabController _tabController;
  int selectedTabIndex = 0;

  String? type;
  List<String>? fetchedlink;
  List<String>? fetchedTitle;
  List<int>? fetchedlinkid;
  bool _isLoading = true; // Manage loading state

  @override
  void initState() {
    super.initState();
    _createTutorial();
    Timer(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
    // on app startup, fetch the existing notes
    readIngeadints(widget.dish!, widget.serial!);
    readRecipe(widget.dish!, widget.type!, widget.serial!);
    readLink(widget.serial!);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        selectedTabIndex = _tabController.index;
      });
    });
  }

  List<String> images = [
    'https://img.freepik.com/free-photo/breakfast-consists-bread-fried-egg-salad-dressing-black-grapes-tomatoes-sliced-a-a-onions_1150-24459.jpg?t=st=1737460645~exp=1737464245~hmac=211ae8a793b1d99d23e0892b0f71f4b0efecbc65ea11ee8131a0fc260f287918&w=1380',
    'https://images.pexels.com/photos/25225626/pexels-photo-25225626/free-photo-of-sandwich-baked-potatoes-and-salad-on-plate.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/1618913/pexels-photo-1618913.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/19834448/pexels-photo-19834448/free-photo-of-soup-and-spices.jpeg',
    'https://images.pexels.com/photos/5602707/pexels-photo-5602707.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/3504874/pexels-photo-3504874.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/3356409/pexels-photo-3356409.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/1320998/pexels-photo-1320998.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/14774693/pexels-photo-14774693.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/6660071/pexels-photo-6660071.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final GlobalKey _link = GlobalKey();
  final GlobalKey _add = GlobalKey();

  Future<void> _createTutorial() async {
    // Get SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();

    // Check if the tutorial has already been shown
    bool isTutorialShown = prefs.getBool('tutorialShownrecipe') ?? false;

    // If it has been shown, return early
    if (isTutorialShown) return;

    // Define the tutorial targets
    final targets = [
      TargetFocus(
        identify: '_add',
        keyTarget: _add,
        alignSkip: Alignment.bottomCenter,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.03),
              child: Container(
                padding: const EdgeInsets.all(12), // Inner padding
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10), // Rounded edges
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Lottie.asset('assets/lottie_json/recipetu.json',
                        repeat: true,
                        height: MediaQuery.of(context).size.width * 0.3),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Text(
                        'Use this button to add new Ingredients / Instructions',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.hammersmithOne(
                          color: Colors.black,
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'floatingButton',
        keyTarget: _link,
        alignSkip: Alignment.bottomCenter,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.07),
              child: Container(
                padding: const EdgeInsets.all(12), // Inner padding
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10), // Rounded edges
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Lottie.asset('assets/lottie_json/youtube.json',
                            repeat: true,
                            width: MediaQuery.of(context).size.width * 0.4),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: Text(
                            'Use this button to add reference links from YouTube and more',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.hammersmithOne(
                              color: Colors.black,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Long press this button to update or add more links',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.hammersmithOne(
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                      ),
                    ),
                  ],
                ),
              ),
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
      prefs.setBool('tutorialShownrecipe', true);
    });
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            // Return false to prevent back button from closing the dialog
            return false;
          },
          child: AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(
                  strokeWidth: 5,
                  color: (Theme.of(context).primaryColor),
                ),
                SizedBox(width: 20),
                Text("Processing...", style: GoogleFonts.hammersmithOne()),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchUrl(List<String> fetchedLinks, List<int> fetchedLinksId,
      List<String> title) async {
    if (fetchedLinks.isEmpty) return;

    String? selectedLink;

    if (fetchedLinks.length == 1) {
      selectedLink = fetchedLinks.first;
    } else {
      selectedLink = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              width: MediaQuery.of(context).size.width * 0.9,
              height: fetchedLinks.length > 2
                  ? 400
                  : 300, // Height for better visibility
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Manage Links",
                        style: GoogleFonts.hammersmithOne(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),

                  // Content Area
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: fetchedLinks.length,
                      itemBuilder: (BuildContext context, int index) {
                        String link = fetchedLinks[index];
                        String name = title[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 6.0, horizontal: 8.0),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.only(
                                top: 5.0, bottom: 5, left: 15),
                            title: Text(
                              name.length > 20
                                  ? '${name.substring(0, 20)}...'
                                  : name,
                              style: GoogleFonts.hammersmithOne(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              link.length > 30
                                  ? '${link.substring(0, 30)}...'
                                  : link,
                              style: GoogleFonts.hammersmithOne(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                // Show confirmation dialog
                                bool? confirmDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Confirm Deletion',
                                          style: GoogleFonts.hammersmithOne()),
                                      content: Text(
                                          'Are you sure you want to delete "$name"?',
                                          style: GoogleFonts.hammersmithOne()),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: Text('Cancel',
                                              style:
                                                  GoogleFonts.hammersmithOne()),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: Text('Delete',
                                              style:
                                                  GoogleFonts.hammersmithOne()),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirmDelete == true) {
                                  // Proceed with deletion
                                  String linkName = title[index];
                                  await deleteLink(linkName);

                                  setState(() {
                                    fetchedLinks.removeAt(index);
                                    fetchedLinksId.removeAt(index);
                                  });
                                  Navigator.pop(context);
                                }
                              },
                            ),
                            onTap: () => Navigator.pop(context, link),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    if (selectedLink != null) {
      final Uri _url = Uri.parse(selectedLink);
      if (!await launchUrl(_url)) {
        throw Exception('Could not launch $_url');
      }
    }
  }

/* Future<void> deleteLink(int id, String type, String dish) async {
  await isar!.writeTxn(() => isar!.recipes.delete(id)); // Deleting the item
  readLink(dish, type); // Fetch updated list after deletion
} */

  /* Future<List<Map<String, String>>> _fetchLink() async {
    // Check if isar instance is null before proceeding
    if (isar == null) {
      return []; // Return an empty list if isar is null
    }

    final link = await isar!.links
        .filter()
        .dishEqualTo(dish)
        .and()
        .typeEqualTo(type)
        .findAll();

    // Check if link is null before proceeding
    if (link == null || link.isEmpty) {
      return []; // Return an empty list if no matching link found
    }

    // Convert the list of links into a list of maps
    return link.map((link) {
      return {
        'link': link.link ?? '', // Provide a fallback for null links
      };
    }).toList();
  }

  Future<void> _loadLinkData() async {
    print('Initializing Isar...');
    if (isar == null) {
      print('Isar instance is null.');
    } else {
      print('Isar instance initialized: $isar');
    }

    final data = await _fetchLink();
    setState(() {
      linkData = data;
    });
  } */

  //function to create a note
  void createIngredient() {
    TextEditingController quantityController = TextEditingController();
    TextEditingController textController = TextEditingController();
    bool isName = false; // Flag for empty text field error message
    bool isQuantity = false; // Flag for empty text field error message
    bool isUOM = false; // Flag for empty text field error message

    String? selectedUnit;
    final List<String> unitOptions = [
      'gm',
      'kg',
      'ltr',
      'nos',
      'pcs',
      'cup',
      'tsp',
      'tbsp'
    ];

    void clearInputs() {
      textController.clear();
      quantityController.clear();
      selectedUnit = null;
    }

    String pluralizeUnit(String unit, int quantity) {
      if (quantity <= 1) return unit;
      switch (unit) {
        case 'cup':
          // return 'cups';
          return 'cup';
        case 'tsp':
          //return 'spoons';
          return 'tsp';
        case 'tbsp':
          //return 'spoons';
          return 'tbsp';
        case 'pc':
          return 'pcs';
        case 'gm':
          return 'gm';
        case 'kg':
          return 'kgs';
        case 'ltr':
          return 'ltrs';
        default:
          return unit;
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              'Add Ingredient',
              style: GoogleFonts.hammersmithOne(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Container(
              width:
                  MediaQuery.of(context).size.width * 0.6, // Adjust the width
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ingredient Name Input
                    TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        labelStyle:
                            GoogleFonts.hammersmithOne(color: Colors.black),
                        labelText: 'Ingredient Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: Colors.grey[300]!), // Default border color
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: Colors
                                  .grey[300]!), // Border color when focused
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: Colors
                                  .grey[300]!), // Border color when not focused
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    if (isName)
                      Text(
                        'Please enter a ingredient name.',
                        style: GoogleFonts.hammersmithOne(
                            color: Colors.red.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),

                    const SizedBox(height: 20),

                    // Quantity and Unit in One Row
                    Row(
                      children: [
                        // Quantity Input
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              TextField(
                                controller: quantityController,
                                decoration: InputDecoration(
                                  labelStyle: GoogleFonts.hammersmithOne(
                                      color: Colors.black),
                                  labelText: 'Quantity',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.grey[
                                            300]!), // Default border color
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.grey[
                                            300]!), // Border color when focused
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.grey[
                                            300]!), // Border color when not focused
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Unit Dropdown
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelStyle: GoogleFonts.hammersmithOne(
                                      color: Colors.black),
                                  labelText: 'Unit',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.grey[
                                            300]!), // Default border color
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.grey[
                                            300]!), // Border color when focused
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.grey[
                                            300]!), // Border color when not focused
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                isExpanded: true,
                                items: unitOptions.map((String unit) {
                                  return DropdownMenuItem<String>(
                                    value: unit,
                                    child: Text(unit,
                                        style: GoogleFonts.hammersmithOne()),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  setState(() => selectedUnit = value);
                                },
                                value: selectedUnit,
                                hint: Text('Select',
                                    style: GoogleFonts.hammersmithOne()),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Text(
                      "Note: Enter 0.5 for 1/2 and 0.25 for 1/4.",
                      style: GoogleFonts.hammersmithOne(fontSize: 12),
                    ),
                    if (isUOM || isQuantity) const SizedBox(height: 10),
                    if (isUOM)
                      Text(
                        'Please select UOM.',
                        style: GoogleFonts.hammersmithOne(
                            color: Colors.red.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    if (isQuantity)
                      Text(
                        'Please enter quantity.',
                        style: GoogleFonts.hammersmithOne(
                            color: Colors.red.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                  ],
                ),
              ),
            ),
            actionsPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            actions: [
              // Cancel Button
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  clearInputs();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textStyle: GoogleFonts.hammersmithOne(fontSize: 16),
                ),
                child: Text('Cancel', style: GoogleFonts.hammersmithOne()),
              ),

              // Create Button
              ElevatedButton(
                onPressed: () async {
                  final ingredientName = textController.text.trim();
                  final quantityText = quantityController.text.trim();
                  final quantity = double.tryParse(quantityText);

                  // Validate ingredient name
                  if (ingredientName.isEmpty) {
                    setState(() {
                      isName = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Ingredient name is required.',
                              style: GoogleFonts.hammersmithOne())),
                    );
                    return;
                  } else {
                    setState(() {
                      isName = false;
                    });
                  }

                  // Validate quantity
                  if (quantity == null ||
                      quantity <= 0 ||
                      (quantity < 1 && quantity != 0.25 && quantity != 0.5)) {
                    setState(() {
                      isQuantity = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Please enter a valid quantity (e.g., 0.25, 0.5, or values >= 1).',
                              style: GoogleFonts.hammersmithOne())),
                    );
                    return;
                  } else {
                    setState(() {
                      isQuantity = false;
                    });
                  }

                  // Validate unit of measurement (UOM)
                  if (selectedUnit == null) {
                    setState(() {
                      isUOM = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Please select a unit.',
                              style: GoogleFonts.hammersmithOne())),
                    );
                    return;
                  } else {
                    setState(() {
                      isUOM = false;
                    });
                  }

                  // Adjust unit for quantity
                  final adjustedUnit =
                      pluralizeUnit(selectedUnit!, quantity.toInt());

                  // Assuming addIngredient method is available in the database provider
                  await context.read<database>().addIngredient(
                        widget.serial!,
                        ingredientName,
                        widget.type!,
                        widget.dish!,
                        quantityText,
                        adjustedUnit,
                        widget.category!,
                      );

                  Navigator.pop(context);
                  clearInputs();
                  readIngeadints(widget.dish!, widget.serial!);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.background,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: GoogleFonts.hammersmithOne(fontSize: 16),
                ),
                child: Text('Create', style: GoogleFonts.hammersmithOne()),
              ),
            ],
          );
        },
      ),
    );
  }

  //read notes
  void readIngeadints(String dish, String? serial) {
    context.read<database>().fetchIngredients(dish, serial);
  }

  //update note
  Future<void> updateIng(Ingredients ingredient, String rec) async {
    final response = await Supabase.instance.client
        .from('ingredients')
        .select('id')
        .eq('name', rec);

    final data = List<Map<String, dynamic>>.from(response);
    int ingredientId = data.isNotEmpty ? data[0]['id'] : '';

    TextEditingController textController =
        TextEditingController(text: ingredient.name);
    TextEditingController quantityController =
        TextEditingController(text: ingredient.quantity);
    bool isName = false; // Flag for empty text field error message
    bool isQuantity = false; // Flag for empty text field error message
    bool isUOM = false; // Flag for empty text field error message

    final unitMap = {
      'gms': 'gm',
      'kgs': 'kg',
      'ltrs': 'ltr',
      'nos': 'nos',
      'pcs': 'pc',
      'cups': 'cup',
      'tsp': 'tsp',
      'tbsp': 'tbsp',
    };

    String? selectedUnit = unitMap[ingredient.uom] ?? ingredient.uom;

    List<String> unitOptions = [
      'nos',
      'pc',
      'gm',
      'kg',
      'ltr',
      'cup',
      'tsp',
      'tbsp'
    ];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Ingredient',
                  style: GoogleFonts.hammersmithOne(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Confirm Action",
                            style: GoogleFonts.hammersmithOne()),
                        content: Text(
                            "Are you sure you want to delete this ingredient?",
                            style: GoogleFonts.hammersmithOne()),
                        actions: [
                          TextButton(
                            onPressed: () {
                              deleteIng(rec);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Text("Yes, Delete",
                                style: GoogleFonts.hammersmithOne(
                                    color: Colors.red)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Cancel",
                                style: GoogleFonts.hammersmithOne()),
                          ),
                        ],
                      ),
                    );
                  },
                  icon:
                      Icon(Icons.delete, color: Colors.red.shade800, size: 20),
                ),
              ],
            ),
            content: Container(
              width: MediaQuery.of(context).size.width * 0.6, // Wider dialog
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ingredient Name Input
                    TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        labelText: 'Ingredient Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                    if (isName)
                      Text(
                        'Please enter a ingredient name.',
                        style: GoogleFonts.hammersmithOne(
                            color: Colors.red.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),

                    const SizedBox(height: 20),
                    // Quantity and Unit in One Row
                    Row(
                      children: [
                        // Quantity Input
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              TextField(
                                controller: quantityController,
                                decoration: InputDecoration(
                                  labelText: 'Quantity',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Unit Dropdown
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Unit',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                ),
                                isExpanded: true,
                                items: unitOptions.map((String unit) {
                                  return DropdownMenuItem<String>(
                                    value: unit,
                                    child: Text(unit,
                                        style: GoogleFonts.hammersmithOne()),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  setState(() => selectedUnit = value);
                                },
                                value: selectedUnit,
                                hint: Text('Select',
                                    style: GoogleFonts.hammersmithOne()),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "Note: Enter 0.5 for 1/2 and 0.25 for 1/4.",
                      style: GoogleFonts.hammersmithOne(fontSize: 12),
                    ),
                    if (isUOM || isQuantity) const SizedBox(height: 10),
                    if (isUOM)
                      Text(
                        'Please select UOM.',
                        style: GoogleFonts.hammersmithOne(
                            color: Colors.red.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    if (isQuantity)
                      Text(
                        'Please enter quantity.',
                        style: GoogleFonts.hammersmithOne(
                            color: Colors.red.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                  ],
                ),
              ),
            ),
            actionsPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            actions: [
              // Cancel Button
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textStyle: GoogleFonts.hammersmithOne(fontSize: 16),
                ),
                child: Text('Cancel', style: GoogleFonts.hammersmithOne()),
              ),

              // Update Button
              ElevatedButton(
                onPressed: () async {
                  final ingredientName = textController.text.trim();
                  final quantityText = quantityController.text.trim();
                  final quantity = double.tryParse(quantityText);

                  if (ingredientName.isEmpty) {
                    setState(() {
                      isName = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Ingredient name is required.',
                              style: GoogleFonts.hammersmithOne())),
                    );
                    return;
                  } else {
                    setState(() {
                      isName = false;
                    });
                  }
                  if (quantity == null ||
                      quantity <= 0 ||
                      (quantity < 1 && quantity != 0.25 && quantity != 0.5)) {
                    setState(() {
                      isQuantity = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Please enter a valid quantity (e.g., 0.25, 0.5, or values >= 1).',
                              style: GoogleFonts.hammersmithOne())),
                    );
                    return;
                  } else {
                    setState(() {
                      isQuantity = false;
                    });
                  }

                  // Validate unit of measurement (UOM)
                  if (selectedUnit == null) {
                    setState(() {
                      isUOM = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Please select a unit.',
                              style: GoogleFonts.hammersmithOne())),
                    );
                    return;
                  } else {
                    setState(() {
                      isUOM = false;
                    });
                  }

                  // Adjust unit for quantity

                  if (selectedUnit == null) {
                    setState(() {
                      // Check if the text field is empty
                      isUOM = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Please select a unit.',
                              style: GoogleFonts.hammersmithOne())),
                    );
                    return;
                  } else {
                    setState(() {
                      isUOM = false;
                    });
                  }
                  if (textController.text.isNotEmpty &&
                      quantityController.text.isNotEmpty &&
                      selectedUnit != null) {
                    int quantity = int.tryParse(quantityController.text) ?? 1;
                    String adjustedUnit = selectedUnit!;

                    // Adjust unit to plural if quantity is more than 1
                    if (quantity > 1) {
                      adjustedUnit = {
                            /* 'cup': 'cups',
                            'tsp'
'tbsp': 'spoons',
                            'pc': 'pcs',
                            'gm': 'gms',
                            'kg': 'kgs',
                            'ltr': 'ltrs' */
                            'cup': 'cup',
                            'tsp': 'tsp',
                            'tbsp': 'tbsp',
                            'pc': 'pcs',
                            'gm': 'gm',
                            'kg': 'kg',
                            'ltr': 'ltr'
                          }[adjustedUnit] ??
                          adjustedUnit;
                    }

                    // Update the ingredient in the database
                    await context.read<database>().updateIngredient(
                          ingredientId,
                          textController.text,
                          widget.type!,
                          quantityController.text,
                          adjustedUnit,
                        );

                    textController.clear();
                    quantityController.clear();
                    readIngeadints(widget.dish!, widget.serial!);

                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.background,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: GoogleFonts.hammersmithOne(fontSize: 16),
                ),
                child: Text('Update', style: GoogleFonts.hammersmithOne()),
              ),
            ],
          );
        },
      ),
    );
  }

  //delete a note
  void deleteIng(String rec) async {
    final response = await Supabase.instance.client
        .from('ingredients')
        .select('id') // Specify the field to fetch
        .eq('name', rec); // Filter by serial

// Convert the response to a list of maps
    final data = List<Map<String, dynamic>>.from(response);

// Clear the previous data if necessary

// Store the id in a string
    int id = data.isNotEmpty ? data[0]['id'] : '';
    await context.read<database>().deleteIngredient(id, widget.type!);
    readIngeadints(widget.dish!, widget.serial!);
  }

  /* void createRecipe() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Add Recipe'),
                content: TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: 'Recipe',
                  ),
                ),
                actions: [
                  //create button
                  MaterialButton(
                      textColor: Colors.white,
                      onPressed: () async {
                        if (textController.text.isNotEmpty) {
                          await context.read<database>().addRecipe(
                              widget.serial!,
                              textController.text,
                              widget.type!,
                              widget.dish!);
                          Navigator.pop(context);
                          readRecipe(
                              widget.dish!, widget.type!, widget.serial!);
                          textController.clear();
                        }
                      },
                      child: Text('Create',
                          style: GoogleFonts.hammersmithOne(
                              color: Theme.of(context)
                                  .colorScheme
                                  .inversePrimary)))
                ]));
  } */
  void createRecipe() {
    bool isTextEmpty = false; // Track if the text is empty after button tap

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0), // Soft rounded edges
            ),
            title: Center(
              child: Text(
                'Add Recipe',
                style: GoogleFonts.hammersmithOne(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: widget.background,
                ),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Write your recipe details below:',
                  style: GoogleFonts.hammersmithOne(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: TextField(
                    controller: textController,
                    maxLines: 6,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'Enter your recipe...',
                      hintStyle:
                          GoogleFonts.hammersmithOne(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2.0,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                // Show the message if the text is empty after button tap
                isTextEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Recipe cannot be empty!',
                          style: GoogleFonts.hammersmithOne(
                            color: Colors.redAccent,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
            actionsAlignment: MainAxisAlignment.end,
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                  textStyle: GoogleFonts.hammersmithOne(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                },
                child: Text('Cancel', style: GoogleFonts.hammersmithOne()),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.background,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () async {
                  if (textController.text.trim().isNotEmpty) {
                    await context.read<database>().addRecipe(
                          widget.serial!,
                          textController.text,
                          widget.type!,
                          widget.dish!,
                        );
                    Navigator.pop(context); // Close the dialog
                    readRecipe(widget.dish!, widget.type!,
                        widget.serial!); // Refresh data
                    textController.clear(); // Clear input
                  } else {
                    // Set state to show the error message
                    setState(() {
                      isTextEmpty = true;
                    });
                  }
                },
                child: Text('Add Recipe', style: GoogleFonts.hammersmithOne()),
              ),
            ],
          );
        },
      ),
    );
  }

  //read notes
  void readRecipe(String dish, String type, String serial) {
    context.read<database>().fetchRecipe(serial);
  }

  //update note
  Future<void> updateRecipe(Recipe name, String rec) async {
    bool isTextEmpty = false; // Track if the text is empty after button tap

    // Fetch the recipe ID from the database
    final response = await Supabase.instance.client
        .from('recipes')
        .select('id')
        .eq('name', rec);

    final data = List<Map<String, dynamic>>.from(response);
    int recipeId = data.isNotEmpty ? data[0]['id'] : 0;

    // Pre-fill the TextField with the current recipe name
    textController.text = name.name!;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0), // Rounded corners
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(" "),
                Text(
                  'Edit Recipe',
                  style: GoogleFonts.hammersmithOne(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: widget.background),
                ),
                IconButton(
                  onPressed: () {
                    // Show delete confirmation dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        title: Text(
                          "Confirm Action",
                          style: GoogleFonts.hammersmithOne(
                              fontWeight: FontWeight.bold),
                        ),
                        content: Text(
                            "Are you sure you want to delete this recipe?",
                            style: GoogleFonts.hammersmithOne()),
                        actions: [
                          TextButton(
                            onPressed: () {
                              deleteRecipe(rec); // Perform the delete action
                              Navigator.pop(
                                  context); // Close confirmation dialog
                              Navigator.pop(context); // Close edit dialog
                            },
                            child: Text(
                              "Yes, Delete",
                              style:
                                  GoogleFonts.hammersmithOne(color: Colors.red),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(
                                  context); // Close confirmation dialog
                            },
                            child: Text("Cancel",
                                style: GoogleFonts.hammersmithOne()),
                          ),
                        ],
                      ),
                    );
                  },
                  icon:
                      Icon(Icons.delete, color: Colors.red.shade800, size: 20),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: TextField(
                    controller: textController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Edit your recipe here...',
                      hintStyle:
                          GoogleFonts.hammersmithOne(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2.0,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                // Show the message if the text is empty after button tap
                isTextEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Recipe cannot be empty!',
                          style: GoogleFonts.hammersmithOne(
                            color: Colors.redAccent,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
            actionsAlignment: MainAxisAlignment.end,
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                  textStyle: GoogleFonts.hammersmithOne(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('Cancel', style: GoogleFonts.hammersmithOne()),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.background,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () async {
                  if (textController.text.trim().isNotEmpty) {
                    // Update the recipe in the database
                    await context.read<database>().updateRecipe(
                          widget.serial!,
                          recipeId,
                          textController.text,
                          widget.type!,
                          widget.dish!,
                        );
                    textController.clear(); // Clear the input
                    readRecipe(widget.dish!, widget.type!,
                        widget.serial!); // Refresh the recipe list
                    Navigator.pop(context); // Close the dialog
                  } else {
                    // Set state to show the error message
                    setState(() {
                      isTextEmpty = true;
                    });
                  }
                },
                child:
                    Text('Update Recipe', style: GoogleFonts.hammersmithOne()),
              ),
            ],
          );
        },
      ),
    );

    // Refresh data after the dialog is closed
    readRecipe(widget.dish!, widget.type!, widget.serial!);
  }

  //delete a note
  void deleteRecipe(String rec) async {
    final response = await Supabase.instance.client
        .from('recipes')
        .select('id') // Specify the field to fetch
        .eq('name', rec); // Filter by serial

// Convert the response to a list of maps
    final data = List<Map<String, dynamic>>.from(response);

// Clear the previous data if necessary

// Store the id in a string
    int id = data.isNotEmpty ? data[0]['id'] : '';
    await context
        .read<database>()
        .deleteRecipe(widget.serial!, id, widget.type!, widget.dish!);
    readRecipe(widget.dish!, widget.type!, widget.serial!);
  }

  void createLink() async {
    TextEditingController titleController = TextEditingController();
    TextEditingController textController = TextEditingController();

    // Regular expression for URL validation
    RegExp urlRegExp = RegExp(
      r'^(https?|ftp):\/\/[^\s/$.?#].[^\s]*$', // Simple URL regex
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Add Link',
          style: GoogleFonts.hammersmithOne(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.6, // Wider dialog
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title Input
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 16),

              // Link Input with URL validation
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  labelText: 'Link',
                  hintText: 'www.youtube.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  errorText: textController.text.isNotEmpty &&
                          !urlRegExp.hasMatch(textController.text)
                      ? 'Enter a valid URL'
                      : null, // Show error message if URL is invalid
                ),
              ),
            ],
          ),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: GoogleFonts.hammersmithOne(fontSize: 16),
            ),
            child: Text('Cancel', style: GoogleFonts.hammersmithOne()),
          ),

          // Create Button
          ElevatedButton(
            onPressed: () async {
              // Validate the URL before proceeding
              if (textController.text.isNotEmpty &&
                  titleController.text.isNotEmpty &&
                  urlRegExp.hasMatch(textController.text)) {
                await context.read<database>().addLink(
                    titleController.text,
                    textController.text,
                    widget.serial!,
                    widget.type!,
                    widget.dish!); // Pass additional data
                Navigator.pop(context);
                readRecipe(widget.dish!, widget.type!, widget.serial!);
                readLink(widget.serial!);

                textController.clear();
                titleController.clear();
              } else {
                // Optionally, show an error message for invalid input
                if (!urlRegExp.hasMatch(textController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a valid URL',
                          style: GoogleFonts.hammersmithOne()),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.background,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: GoogleFonts.hammersmithOne(fontSize: 16),
            ),
            child: Text('Create', style: GoogleFonts.hammersmithOne()),
          ),
        ],
      ),
    );
  }

  //read notes
  void readLink(String serial) async {
    // Await the result of fetchLink to get the actual list of Links
    List<Links> link = await context.read<database>().fetchLink(serial);

    // If the list is not empty, map over it to extract all titles
    if (link.isNotEmpty) {
      // Extract all titles into a List<String>
      List<String> fetchedTitles = link.map((item) => item.link).toList();
      List<int> fetchedTitlesId = link.map((item) => item.id).toList();
      List<String> fetchedName = link.map((item) => item.linkName).toList();
      fetchedlink = fetchedTitles;
      fetchedlinkid = fetchedTitlesId;
      fetchedTitle = fetchedName;
      // Handle the fetched list of titles (e.g., use it, store it, etc.)
      // For example, you can print the list of titles
      print(fetchedTitles);
    } else {
      // Handle case where no links are found
      print('No links found');
    }
  }

  void newLink() async {
    TextEditingController titleController = TextEditingController();
    TextEditingController textController = TextEditingController();

    // Regular expression for URL validation
    RegExp urlRegExp = RegExp(
      r'^(https?|ftp):\/\/[^\s/$.?#].[^\s]*$', // Simple URL regex
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'New Link',
          style: GoogleFonts.hammersmithOne(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.6, // Wider dialog
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title Input
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 16),

              // Link Input with URL validation
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  labelText: 'Link',
                  hintText: 'www.youtube.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  errorText: textController.text.isNotEmpty &&
                          !urlRegExp.hasMatch(textController.text)
                      ? 'Enter a valid URL'
                      : null, // Show error message if URL is invalid
                ),
              ),
            ],
          ),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: GoogleFonts.hammersmithOne(fontSize: 16),
            ),
            child: Text('Cancel', style: GoogleFonts.hammersmithOne()),
          ),

          // Update Button
          ElevatedButton(
            onPressed: () async {
              // Validate the URL before proceeding
              if (textController.text.isNotEmpty &&
                  titleController.text.isNotEmpty &&
                  urlRegExp.hasMatch(textController.text)) {
                await context.read<database>().addLink(
                    titleController.text,
                    textController.text,
                    widget.serial!,
                    widget.type!,
                    widget.dish!); // Pass additional data
                Navigator.pop(context);
                readRecipe(widget.dish!, widget.type!, widget.serial!);
                readLink(widget.serial!);

                textController.clear();
                titleController.clear();
              } else {
                // Optionally, show an error message for invalid input
                if (!urlRegExp.hasMatch(textController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a valid URL',
                          style: GoogleFonts.hammersmithOne()),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.background,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: GoogleFonts.hammersmithOne(fontSize: 16),
            ),
            child: Text('Create', style: GoogleFonts.hammersmithOne()),
          ),
        ],
      ),
    );
  }

  //update note
  /* void updateLink(Recipe name) async {
    //pre-fill the current note text into our controller
    textController.text = name.name!;
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Edit'),
                content: TextField(
                  controller: textController,
                  decoration: const InputDecoration(),
                ),
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
                actions: [
                  MaterialButton(
                      onPressed: () async {
                        //update note in db
                        await context.read<database>().updateLink(name.id,
                            textController.text, widget.type!, widget.dish!);
                        //clear the controller
                        textController.clear();
                        readRecipe(widget.dish!, widget.type!);
                        //pop dialog box
                        Navigator.pop(context);
                      },
                      child: Text('Update',
                          style: GoogleFonts.hammersmithOne(
                              color: Theme.of(context)
                                  .colorScheme
                                  .inversePrimary)))
                ]));
    readRecipe(widget.dish!, widget.type!);
  } */

  //delete a note
  Future<void> deleteLink(String rec) async {
    final response = await Supabase.instance.client
        .from('links')
        .select('id') // Specify the field to fetch
        .eq('linkname', rec); // Filter by serial

// Convert the response to a list of maps
    final data = List<Map<String, dynamic>>.from(response);

// Clear the previous data if necessary

// Store the id in a string
    int id = data.isNotEmpty ? data[0]['id'] : '';
    await context.read<database>().deleteLink(id, widget.serial!);
    readRecipe(widget.dish!, widget.type!, widget.serial!);
  }

  SpeedDial floatingActionButtonMenu(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.add),
          label: 'add Ingredient',
          onTap: createIngredient,
        ),
        SpeedDialChild(
          child: const Icon(Icons.add),
          label: 'add Recipe',
          onTap: () {
            createRecipe();
            textController.clear();
            // Add edit action here
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.delete),
          label: 'Delete Note',
          onTap: () {
            // Add delete action here
          },
        ),
      ],
    );
  }

  Future<void> add(int index) async {
    if (index == 0) {
      createIngredient();
    } else {
      createRecipe();
      textController.clear();
    }
  }

  /* void add() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                createIngredient();
              },
              child: const Text('Add Ingredient'),
            ),
            const SizedBox(width: 20), // Space between buttons
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                createRecipe();
              },
              child: const Text('Add Instructions'),
            ),
          ],
        ),
      ),
    );
  } */

  final List<String> items = [
    '1/4',
    '1/2',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10'
  ];

  String? selectedValue = "1";

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

  @override
  Widget build(BuildContext context) {
    // note database
    final noteDatabase = context.watch<database>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Set responsive font size and padding based on screen width
    double fontSize =
        screenWidth * 0.04; // Adjust font size based on screen width
    double paddingValue =
        screenWidth * 0.02; // Adjust padding based on screen width
    double cellPadding = screenWidth * 0.01; // Padding for table cells

    // Adjust sizes dynamically
    final iconSize =
        screenWidth * 0.07; // Adjust icon size based on screen width
    final titleFontSize = screenWidth * 0.075;
    // current notes
    List<Ingredients> currentNotes = noteDatabase.currentIng;
    List<Recipe> currentRecipe = noteDatabase.currentRecipe;
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        backgroundColor: widget.background,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(screenHeight * 0.12),
          child: AppBar(
            toolbarHeight: screenHeight * 0.08,
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            leading: Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.025, left: 10),
              child: IconButton(
                icon: Icon(
                  FontAwesomeIcons.arrowLeft,
                  color: Colors.white,
                  size: iconSize,
                ),
                onPressed: () {
                  Navigator.pop(context); // Navigate back when pressed
                },
              ),
            ),
            title: Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.037),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment
                    .center, // Ensures items align horizontally
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dish title with icon
                  Flexible(
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // Align text and icon
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Text(
                            widget.dish != null && widget.dish!.length > 17
                                ? '${widget.dish!.substring(0, 15)}...'
                                : widget.dish ?? '',
                            style: GoogleFonts.hammersmithOne(
                              fontSize: titleFontSize,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow
                                .ellipsis, // Prevents overflow issues
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      children: [
                        // Add button
                        if (widget.access!)
                          IconButton(
                            key: _add,
                            onPressed: () => add(selectedTabIndex),
                            icon: SvgPicture.asset(
                              'assets/icons/add.svg',
                              color: Colors
                                  .white, // Make sure to use your correct asset path
                              width: screenWidth *
                                  0.055, // Adjust the size as needed
                            ),
                            tooltip: 'Add item',
                          ),

                        // Link button
                        GestureDetector(
                          key: _link,
                          onTap: () {
                            if (fetchedlink == null) {
                              if (widget.access!) {
                                createLink();
                              } else {
                                const snackBar = SnackBar(
                                  /// need to set following properties for best effect of awesome_snackbar_content
                                  elevation: 0,
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.transparent,
                                  content: AwesomeSnackbarContent(
                                    title: 'OOPS!',
                                    message: 'No links available',

                                    /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                                    contentType: ContentType.warning,
                                    inMaterialBanner: true,
                                  ),
                                );
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(snackBar);
                                return;
                              }
                            } else {
                              final fetchedLinksId = fetchedlinkid is List<int>
                                  ? fetchedlinkid as List<int>
                                  : [fetchedlinkid as int];
                              final fetchedLinks = fetchedlink is List<String>
                                  ? fetchedlink as List<String>
                                  : [fetchedlink as String];
                              final fetchedlinkNames =
                                  fetchedTitle is List<String>
                                      ? fetchedTitle as List<String>
                                      : [fetchedTitle as String];

                              _launchUrl(fetchedLinks, fetchedLinksId,
                                  fetchedlinkNames);
                            }
                          },
                          onLongPress: widget.access!
                              ? fetchedlink == null
                                  ? createLink
                                  : newLink
                              : null,
                          child: SvgPicture.asset(
                            'assets/icons/youtube.svg',
                            color: Colors
                                .white, // Make sure to use your correct asset path
                            width: screenWidth * 0.065,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Ingredients'),
                Tab(text: 'How to Cook'),
              ],
              labelStyle: GoogleFonts.hammersmithOne(
                fontSize: MediaQuery.of(context).size.width * 0.05,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: GoogleFonts.hammersmithOne(
                fontSize: MediaQuery.of(context).size.width * 0.045,
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black87,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 3.0, color: Colors.white),
                insets: EdgeInsets.symmetric(horizontal: 30.0),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: Colors.white,
              overlayColor:
                  MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
              splashBorderRadius: BorderRadius.circular(8),
              dividerColor: Colors.transparent,
            ),
          ),
        ),

        // floatingActionButton: floatingActionButtonMenu(context),
        body: TabBarView(
          controller: _tabController,
          children: [
            Stack(
              children: [
                // Image container
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: screenWidth,
                    height: screenHeight * 0.27,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(screenWidth > 600
                            ? 30.0
                            : 0), // Adjust the radius as needed
                        topRight: Radius.circular(screenWidth > 600 ? 30.0 : 0),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: widget.imageURL ?? '',
                        fit: BoxFit.fitWidth,
                        placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                                color: widget.background)),
                        errorWidget: (context, url, error) =>
                            CachedNetworkImage(
                          imageUrl: images[int.parse(widget.type!) - 1],
                          fit: BoxFit.fitWidth,
                          placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                  color: widget.background)),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                ),

                // Expanded container with slight overlap
                Positioned(
                  top: screenHeight *
                      0.25, // Adjust this value to control the overlap
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.background,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child:
                        // Ingredients Tab
                        SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding:  EdgeInsets.only(
                                top: screenHeight*0.015, right: screenWidth * 0.06, bottom: 10),
                            child: currentNotes.isNotEmpty
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Calculator : ",
                                        style: GoogleFonts.hammersmithOne(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width >
                                                  600
                                              ? 20
                                              : screenWidth * 0.04,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton2<String>(
                                          isExpanded: true,
                                          hint: Row(
                                            children: [
                                              Icon(
                                                Icons.list,
                                                size: MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        600
                                                    ? 16
                                                    : 8,
                                                color: Colors.white,
                                              ),
                                              SizedBox(
                                                width: 4,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  '1',
                                                  style: GoogleFonts
                                                      .hammersmithOne(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width >
                                                                600
                                                            ? 14
                                                            : screenWidth *
                                                                0.025,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          items: items
                                              .map((String item) =>
                                                  DropdownMenuItem<String>(
                                                    value: item,
                                                    child: Text(
                                                      item,
                                                      style: GoogleFonts
                                                          .hammersmithOne(
                                                        fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width >
                                                                600
                                                            ? 14
                                                            : screenWidth *
                                                                0.025,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ))
                                              .toList(),
                                          value: selectedValue,
                                          onChanged: (String? value) {
                                            setState(() {
                                              selectedValue = value;
                                            });
                                          },
                                          buttonStyleData: ButtonStyleData(
                                            height: screenHeight * 0.02,
                                            width: screenWidth * 0.12,
                                            padding: EdgeInsets.only(
                                                left: screenWidth * 0.025,
                                                right: screenWidth * 0.025),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              /* border: Border.all(
                                      color: Colors.black26,
                                    ), */
                                              color: Colors.white,
                                            ),
                                            elevation: 0,
                                          ),
                                          iconStyleData: const IconStyleData(
                                            icon: Icon(
                                              Icons.keyboard_arrow_down,
                                            ),
                                            iconSize: 14,
                                            iconEnabledColor: Colors.black,
                                            iconDisabledColor: Colors.grey,
                                          ),
                                          dropdownStyleData: DropdownStyleData(
                                            maxHeight: 200,
                                            width: screenWidth * 0.12,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: Colors.white,
                                            ),
                                            offset: const Offset(0, -5),
                                            scrollbarTheme: ScrollbarThemeData(
                                              radius: const Radius.circular(5),
                                              thickness: MaterialStateProperty
                                                  .all<double>(1),
                                              thumbVisibility:
                                                  MaterialStateProperty.all<
                                                      bool>(true),
                                            ),
                                          ),
                                          menuItemStyleData:
                                               MenuItemStyleData(
                                            height: screenHeight * 0.03,
                                            padding: EdgeInsets.only(
                                                left: screenWidth * 0.025, right: 14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: _isLoading
                                ? Center(
                                    child: ColorFiltered(
                                    colorFilter: ColorFilter.mode(
                                        Colors.white, BlendMode.srcIn),
                                    child: Lottie.asset(
                                      'assets/lottie_json/loadingspoons.json',
                                      width: screenWidth * 0.4,
                                    ),
                                  )) // Show loading indicator
                                : currentNotes.isEmpty
                                    ? Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: screenHeight * 0.1),
                                          child: GestureDetector(
                                            onTap: createIngredient,
                                            child: Column(
                                              children: [
                                                Lottie.asset(
                                                  'assets/lottie_json/noingredients.json',
                                                  width: screenWidth * 0.5,
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  'No Ingredients Added',
                                                  style: GoogleFonts
                                                      .hammersmithOne(
                                                    fontSize:
                                                        screenWidth * 0.06,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  'Tap to Add',
                                                  style: GoogleFonts
                                                      .hammersmithOne(
                                                    fontSize:
                                                        screenWidth * 0.03,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ), // Show this if list is empty
                                      )
                                    : Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(),
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  1,
                                              child: Table(
                                                columnWidths: {
                                                  0: FlexColumnWidth(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.07),
                                                  1: FlexColumnWidth(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.015),
                                                  2: FlexColumnWidth(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.015),
                                                  3: FlexColumnWidth(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.025),
                                                  // 4: FlexColumnWidth(.1),
                                                },
                                                children: [
                                                  TableRow(
                                                    children: [
                                                      TableCell(
                                                        child: Padding(
                                                          padding: EdgeInsets.only(
                                                              top: cellPadding),
                                                          child: Text(
                                                            "INGREDIENTS",
                                                            style: GoogleFonts
                                                                .hammersmithOne(
                                                              fontSize:
                                                                  fontSize,
                                                              color: Colors
                                                                  .grey[850],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Padding(
                                                          padding: EdgeInsets.only(
                                                              left:
                                                                  cellPadding -
                                                                      1,
                                                              top: cellPadding),
                                                          child: Text(
                                                            'Qty',
                                                            style: GoogleFonts
                                                                .hammersmithOne(
                                                              fontSize:
                                                                  fontSize,
                                                              color: Colors
                                                                  .grey[850],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                            textAlign:
                                                                TextAlign.left,
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Padding(
                                                          padding: EdgeInsets.only(
                                                              top: cellPadding),
                                                          child: Text(
                                                            'Calc',
                                                            style: GoogleFonts
                                                                .hammersmithOne(
                                                              fontSize:
                                                                  fontSize,
                                                              color: Colors
                                                                  .grey[850],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                            textAlign:
                                                                TextAlign.left,
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Padding(
                                                          padding: EdgeInsets.only(
                                                              top: cellPadding,
                                                              left:
                                                                  cellPadding),
                                                          child: Text(
                                                            "Unit",
                                                            style: GoogleFonts
                                                                .hammersmithOne(
                                                              fontSize:
                                                                  fontSize,
                                                              color: Colors
                                                                  .grey[850],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                            textAlign:
                                                                TextAlign.left,
                                                          ),
                                                        ),
                                                      ),
                                                      /*  TableCell(
                                                                        child: Padding(
                                      padding: EdgeInsets.all(cellPadding),
                                      child: Text(
                                        " ${item['uom']!}",
                                        style: GoogleFonts.hammersmithOne(
                                          fontSize: fontSize,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                                                        ),
                                                                      ), */
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.5, // You can set the height you need
                                            child: ListView.builder(
                                              shrinkWrap:
                                                  true, // Ensures ListView only takes as much space as needed
                                              itemCount: currentNotes.length,
                                              itemBuilder: (context, index) {
                                                final note =
                                                    currentNotes[index];
                                                return ingredientList(
                                                  count: selectedValue!,
                                                  dish: widget.dish,
                                                  text: note.name!,
                                                  quantity: double.parse(
                                                      note.quantity!),
                                                  uom: note.uom,
                                                  access: widget.access!,
                                                  onEditPressed: () async {
                                                    await updateIng(
                                                        note, note.name!);
                                                  },
                                                  onDeletePressed: () =>
                                                      deleteIng(note.name!),
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
                  ),
                ),
              ],
            ),

            // Instructions Tab

            SingleChildScrollView(
              child: _isLoading
                  ? Center(
                      child: ColorFiltered(
                      colorFilter:
                          ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      child: Lottie.asset(
                        'assets/lottie_json/loadingspoons.json',
                        width: screenWidth * 0.4,
                      ),
                    )) // Show loading indicator
                  : currentRecipe.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: screenWidth * 0.45),
                            child: GestureDetector(
                              onTap: createRecipe,
                              child: Column(
                                children: [
                                  Lottie.asset(
                                    'assets/lottie_json/norecipe.json',
                                    width: screenWidth * 1,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'No Recipe Found',
                                    style: GoogleFonts.hammersmithOne(
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Tap to Add',
                                    style: GoogleFonts.hammersmithOne(
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
                      : Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  top:
                                      MediaQuery.of(context).size.height * 0.02,
                                  bottom: MediaQuery.of(context).size.height *
                                      0.01),
                              child: Text(
                                "How to Cook",
                                style: GoogleFonts.hammersmithOne(
                                  fontSize:
                                      MediaQuery.of(context).size.width > 600
                                          ? 22
                                          : MediaQuery.of(context).size.width *
                                              0.05,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            ListView.builder(
                              physics:
                                  const NeverScrollableScrollPhysics(), // Disable individual scrolling
                              shrinkWrap:
                                  true, // Ensures the ListView takes minimal height
                              padding:
                                  EdgeInsets.zero, // Remove any default padding

                              itemCount: currentRecipe.length,
                              itemBuilder: (context, index) {
                                final note = currentRecipe[index];
                                return RecipeList(
                                  dish: widget.dish,
                                  //  type: widget.type!,
                                  text: note.name!,
                                  access: widget.access,
                                  onEditPressed: () =>
                                      updateRecipe(note, note.name!),
                                  onDeletePressed: () =>
                                      deleteRecipe(note.name!),
                                );
                              },
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

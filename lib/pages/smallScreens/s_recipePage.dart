import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar/isar.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:recipe/collections/links.dart';
import 'package:recipe/collections/names.dart';
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
      required this.background});
  String? serial;
  String? type;
  String? dish;
  String? category;
  bool? access;
  Color? background;

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
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => Text(
              'Use this button to add new ingredients/instructions',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'floatingButton',
        keyTarget: _link,
        alignSkip: Alignment.bottomCenter,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => Text(
              'Use this button to add reference links',
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
                Text("Processing..."),
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
                      const Text(
                        "Manage Links",
                        style: TextStyle(
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
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              link,
                              style: TextStyle(
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
                                      title: const Text('Confirm Deletion'),
                                      content: Text(
                                          'Are you sure you want to delete "$name"?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Delete'),
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
      'spoon'
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
        case 'spoon':
          //return 'spoons';
          return 'spoon';
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
            title: const Text(
              'Add Ingredient',
              style: TextStyle(
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
                        labelStyle: TextStyle(color: Colors.black),
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
                        style: TextStyle(
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
                                  labelStyle: TextStyle(color: Colors.black),
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
                              if (isQuantity)
                                Text(
                                  'Please enter quantity.',
                                  style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
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
                                  labelStyle: TextStyle(color: Colors.black),
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
                                    child: Text(unit),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  setState(() => selectedUnit = value);
                                },
                                value: selectedUnit,
                                hint: const Text('Select'),
                              ),
                              if (isUOM)
                                Text(
                                  'Please select UOM.',
                                  style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
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
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('Cancel'),
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
                      const SnackBar(
                          content: Text('Ingredient name is required.')),
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
                      const SnackBar(
                          content: Text(
                              'Please enter a valid quantity (e.g., 0.25, 0.5, or values >= 1).')),
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
                      const SnackBar(content: Text('Please select a unit.')),
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
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('Create'),
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
  void updateIng(Ingredients ingredient, String rec) async {
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
      'spoons': 'spoon',
    };

    String? selectedUnit = unitMap[ingredient.uom] ?? ingredient.uom;

    List<String> unitOptions = ['nos', 'pc', 'gm', 'kg', 'ltr', 'cup', 'spoon'];

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
                const Text(
                  'Edit Ingredient',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Confirm Action"),
                        content: const Text(
                            "Are you sure you want to delete this ingredient?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              deleteIng(rec);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text("Yes, Delete"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel"),
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
                        style: TextStyle(
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
                              if (isQuantity)
                                Text(
                                  'Please enter quantity.',
                                  style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
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
                                    child: Text(unit),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  setState(() => selectedUnit = value);
                                },
                                value: selectedUnit,
                                hint: const Text('Select'),
                              ),
                              if (isUOM)
                                Text(
                                  'Please select UOM.',
                                  style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
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
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('Cancel'),
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
                      const SnackBar(
                          content: Text('Ingredient name is required.')),
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
                      const SnackBar(
                          content: Text(
                              'Please enter a valid quantity (e.g., 0.25, 0.5, or values >= 1).')),
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
                      const SnackBar(content: Text('Please select a unit.')),
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
                      const SnackBar(content: Text('Please select a unit.')),
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
                            'spoon': 'spoons',
                            'pc': 'pcs',
                            'gm': 'gms',
                            'kg': 'kgs',
                            'ltr': 'ltrs' */
                            'cup': 'cup',
                            'spoon': 'spoon',
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
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('Update'),
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
                          style: TextStyle(
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
                style: TextStyle(
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
                  style: TextStyle(
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
                      hintStyle: TextStyle(color: Colors.grey[400]),
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
                          style: TextStyle(
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
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                },
                child: const Text('Cancel'),
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
                child: const Text('Add Recipe'),
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
  void updateRecipe(Recipe name, String rec) async {
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
                  style: TextStyle(
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
                        title: const Text(
                          "Confirm Action",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: const Text(
                          "Are you sure you want to delete this recipe?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              deleteRecipe(rec); // Perform the delete action
                              Navigator.pop(
                                  context); // Close confirmation dialog
                              Navigator.pop(context); // Close edit dialog
                            },
                            child: const Text(
                              "Yes, Delete",
                              style: TextStyle(color: Colors.red),
                            ),
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
                      hintStyle: TextStyle(color: Colors.grey[400]),
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
                          style: TextStyle(
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
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: const Text('Cancel'),
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
                child: const Text('Update Recipe'),
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

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Add Link',
          style: TextStyle(
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

              // Link Input
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
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: const Text('Cancel'),
          ),

          // Create Button
          ElevatedButton(
            onPressed: () async {
              if (textController.text.isNotEmpty &&
                  titleController.text.isNotEmpty) {
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
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.background,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: const Text('Create'),
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

  void newLink() {
    TextEditingController titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'New Link',
          style: TextStyle(
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

              // Link Input
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
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: const Text('Cancel'),
          ),

          // Update Button
          ElevatedButton(
            onPressed: () async {
              if (textController.text.isNotEmpty &&
                  titleController.text.isNotEmpty) {
                await context.read<database>().addLink(
                      titleController.text,
                      textController.text,
                      widget.serial!,
                      widget.type!,
                      widget.dish!,
                    ); // Pass title and description
                Navigator.pop(context);
                readRecipe(widget.dish!, widget.type!, widget.serial!);
                readLink(widget.serial!);
                textController.clear();
                titleController.clear();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.background,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: const Text('Update'),
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
                          style: TextStyle(
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
    final titleFontSize = screenWidth * 0.08;
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
                            widget.dish != null && widget.dish!.length > 15
                                ? '${widget.dish!.substring(0, 12)}...'
                                : widget.dish ?? '',
                            style: GoogleFonts.poppins(
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
                                  0.05, // Adjust the size as needed
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('No links available')),
                                );
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
                          onLongPress: () {
                            if (widget.access!) newLink;
                          },
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
                Tab(text: 'Instructions'),
              ],
              labelStyle: GoogleFonts.montserrat(
                fontSize: MediaQuery.of(context).size.width * 0.05,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: GoogleFonts.montserrat(
                fontSize: MediaQuery.of(context).size.width * 0.035,
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black87,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 3.0, color: Colors.white),
                insets: EdgeInsets.symmetric(horizontal: 20.0),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: Colors.white,
              overlayColor:
                  MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
              splashBorderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        // floatingActionButton: floatingActionButtonMenu(context),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Ingredients Tab
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, right: 30.0, bottom: 10),
                    child: currentNotes.isNotEmpty
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "Calculator : ",
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width > 600
                                          ? 20
                                          : 15,
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
                                        size:
                                            MediaQuery.of(context).size.width >
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
                                          style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width >
                                                    600
                                                ? 14
                                                : 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                          overflow: TextOverflow.ellipsis,
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
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        600
                                                    ? 14
                                                    : 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                              overflow: TextOverflow.ellipsis,
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
                                    height: 30,
                                    width: 60,
                                    padding: const EdgeInsets.only(
                                        left: 14, right: 14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
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
                                    width: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: Colors.white,
                                    ),
                                    offset: const Offset(0, 0),
                                    scrollbarTheme: ScrollbarThemeData(
                                      radius: const Radius.circular(40),
                                      thickness:
                                          MaterialStateProperty.all<double>(6),
                                      thumbVisibility:
                                          MaterialStateProperty.all<bool>(true),
                                    ),
                                  ),
                                  menuItemStyleData: const MenuItemStyleData(
                                    height: 40,
                                    padding:
                                        EdgeInsets.only(left: 14, right: 14),
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
                            colorFilter:
                                ColorFilter.mode(Colors.white, BlendMode.srcIn),
                            child: Lottie.asset(
                              'assets/lottie_json/loadingspoons.json',
                              width: screenWidth * 0.4,
                            ),
                          )) // Show loading indicator
                        : currentNotes.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: screenWidth * 0.48),
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
                                          style: GoogleFonts.poppins(
                                            fontSize: screenWidth * 0.05,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'Tap to Add',
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
                            : Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(),
                                    child: Container(
                                      width:
                                          MediaQuery.of(context).size.width * 1,
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
                                                    style: TextStyle(
                                                      fontSize: fontSize,
                                                      color: Colors.grey[850],
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TableCell(
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      left: cellPadding - 1,
                                                      top: cellPadding),
                                                  child: Text(
                                                    'Qty',
                                                    style: TextStyle(
                                                      fontSize: fontSize,
                                                      color: Colors.grey[850],
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ),
                                              ),
                                              TableCell(
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      top: cellPadding),
                                                  child: Text(
                                                    'Calc',
                                                    style: TextStyle(
                                                      fontSize: fontSize,
                                                      color: Colors.grey[850],
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ),
                                              ),
                                              TableCell(
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      top: cellPadding,
                                                      left: cellPadding),
                                                  child: Text(
                                                    "Unit",
                                                    style: TextStyle(
                                                      fontSize: fontSize,
                                                      color: Colors.grey[850],
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ),
                                              ),
                                              /*  TableCell(
                                                                        child: Padding(
                                      padding: EdgeInsets.all(cellPadding),
                                      child: Text(
                                        " ${item['uom']!}",
                                        style: TextStyle(
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
                                  ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(), // Disable individual scrolling
                                    shrinkWrap:
                                        true, // Ensures the ListView takes minimal height
                                    itemCount: currentNotes.length,
                                    itemBuilder: (context, index) {
                                      final note = currentNotes[index];
                                      return ingredientList(
                                        count: selectedValue!,
                                        dish: widget.dish,
                                        //type: widget.type!,
                                        text: note.name!,
                                        quantity: double.parse(note.quantity!),
                                        uom: note.uom,
                                        access: widget.access!,
                                        onEditPressed: () =>
                                            updateIng(note, note.name!),
                                        onDeletePressed: () =>
                                            deleteIng(note.name!),
                                      );
                                    },
                                  ),
                                ],
                              ),
                  ),
                ],
              ),
            ),
            // Instructions Tab

            SingleChildScrollView(
              child: _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator()) // Show loading indicator
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
                                    style: GoogleFonts.poppins(
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Tap to Add',
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
                      : Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                "How to Cook",
                                style: TextStyle(
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

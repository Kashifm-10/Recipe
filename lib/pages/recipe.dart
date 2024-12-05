import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar/isar.dart';
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
import 'dart:async'; // For using Timer

class recipe extends StatefulWidget {
  recipe(
      {super.key,
      required this.serial,
      required this.type,
      required this.dish,
      required this.category});
  String? serial;
  String? type;
  String? dish;
  String? category;

  @override
  State<recipe> createState() => _recipeState();
}

final isar = IsarInstance().isar;

class _recipeState extends State<recipe> with SingleTickerProviderStateMixin {
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
    Timer(const Duration(seconds: 1), () {
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
          return AlertDialog(
            // title: const Text(''),
            content: Container(
              width: 0.0, // Set the desired width
              height: 200.0, // Set the desired height
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 0.0),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: fetchedLinks.length,
                            itemBuilder: (BuildContext context, int index) {
                              String link = fetchedLinks[index];
                              String name = title[index];

                              return Column(
                                children: [
                                  ListTile(
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          name.length > 15
                                              ? '${name.substring(0, 15)}...'
                                              : name, // Limiting to 20 characters
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        // const Divider(endIndent: 30,),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () async {
                                            String linkName = title[index];
                                            await deleteLink(linkName);

                                            setState(() {
                                              fetchedLinks.removeAt(index);
                                              fetchedLinksId.removeAt(index);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    /*  trailing: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 0.0),
                                      child: IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () async {
                                          int linkId = fetchedLinksId[index];
                                          await deleteLink(linkId);

                                          setState(() {
                                            fetchedLinks.removeAt(index);
                                            fetchedLinksId.removeAt(index);
                                          });
                                        },
                                      ),
                                    ), */
                                    onTap: () {
                                      Navigator.pop(context, link);
                                    },
                                  ),
                                  const Divider(
                                    indent: 35,
                                    endIndent: 55,
                                    height: 0,
                                  )
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
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

    String? selectedUnit;
    List<String> unitOptions = ['gm', 'kg', 'ltr', 'nos', 'pc', 'cup', 'spoon'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('Add Ingredient'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Text field for the ingredient name
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: 'Ingredient',
                  ),
                ),
                const SizedBox(height: 10),

                // Text field for quantity
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    hintText: 'Quantity',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),

                // Dropdown button for selecting a unit
                DropdownButton<String>(
                  hint: const Text('Select Unit'),
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
                ),
              ],
            ),
            actions: [
              // Create button
              MaterialButton(
                textColor: Colors.white,
                onPressed: () async {
                  if (textController.text.isNotEmpty &&
                      quantityController.text.isNotEmpty &&
                      selectedUnit != null) {
                    int quantity = int.tryParse(quantityController.text) ?? 1;
                    String adjustedUnit = selectedUnit!;

                    // Adjust unit to plural if quantity is more than 1
                    if (quantity > 1) {
                      if (adjustedUnit == 'cup') {
                        adjustedUnit = 'cups';
                      } else if (adjustedUnit == 'spoon') {
                        adjustedUnit = 'spoons';
                      } else if (adjustedUnit == 'pc') {
                        adjustedUnit = 'pcs';
                      } else if (adjustedUnit == 'gm') {
                        adjustedUnit = 'gms';
                      } else if (adjustedUnit == 'kg') {
                        adjustedUnit = 'kgs';
                      } else if (adjustedUnit == 'ltr') {
                        adjustedUnit = 'ltrs';
                      }
                    }

                    // Assuming addIngredient method is modified to accept quantity and unit
                    await context.read<database>().addIngredient(
                          widget.serial!,
                          textController.text,
                          widget.type!,
                          widget.dish!,
                          quantityController.text,
                          adjustedUnit,
                          widget.category!,
                        );

                    Navigator.pop(context);
                    readIngeadints(widget.dish!, widget.serial!);
                    textController.clear();
                    quantityController.clear();
                  }
                },
                child: Text(
                  'Create',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
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
  void readIngeadints(String dish, String? serial) {
    context.read<database>().fetchIngredients(dish, serial);
  }

  //update note
  void updateIng(Ingredients ingredient, String rec) async {
    final response = await Supabase.instance.client
        .from('ingredients')
        .select('id') // Specify the field to fetch
        .eq('name', rec); // Filter by serial

// Convert the response to a list of maps
    final data = List<Map<String, dynamic>>.from(response);

// Clear the previous data if necessary

// Store the id in a string
    int ingredientId = data.isNotEmpty ? data[0]['id'] : '';
    // Create controllers for the text fields and unit selection
    TextEditingController textController =
        TextEditingController(text: ingredient.name);
    TextEditingController quantityController =
        TextEditingController(text: ingredient.quantity);
    // Define a map of plural to singular units
    final unitMap = {
      'gms': 'gm',
      'kgs': 'kg',
      'ltrs': 'ltr',
      'nos': 'nos', // Assuming 'nos' is already in singular form
      'pcs': 'pc',
      'cups': 'cup',
      'spoons': 'spoon',
    };

// Set selectedUnit based on the map
    String? selectedUnit = unitMap[ingredient.uom] ?? ingredient.uom;

    /*  String? selectedUnit =
        ingredient.uom; // Assuming Ingredients has a unit field */

    // Dropdown selection options
    List<String> unitOptions = ['nos', 'pc', 'gm', 'kg', 'ltr', 'cup', 'spoon'];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Row(
              children: [
                const Text('Edit Ingredient'),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Confirm Deletion"),
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
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: 'Ingredient',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    hintText: 'Quantity',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  hint: const Text('Select Unit'),
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
                ),
              ],
            ),
            actions: [
              MaterialButton(
                textColor: Colors.white,
                onPressed: () async {
                  if (textController.text.isNotEmpty &&
                      quantityController.text.isNotEmpty &&
                      selectedUnit != null) {
                    int quantity = int.tryParse(quantityController.text) ?? 1;
                    String adjustedUnit = selectedUnit!;

                    // Adjust unit to plural if quantity is more than 1
                    if (quantity > 1) {
                      if (adjustedUnit == 'cup') {
                        adjustedUnit = 'cups';
                      } else if (adjustedUnit == 'spoon') {
                        adjustedUnit = 'spoons';
                      } else if (adjustedUnit == 'pc') {
                        adjustedUnit = 'pcs';
                      } else if (adjustedUnit == 'gm') {
                        adjustedUnit = 'gms';
                      } else if (adjustedUnit == 'kg') {
                        adjustedUnit = 'kgs';
                      } else if (adjustedUnit == 'ltr') {
                        adjustedUnit = 'ltrs';
                      }
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
                child: Text(
                  'Update',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Recipe'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
          child: TextField(
            controller: textController,
            maxLines: null, // Allows the TextField to expand as needed
            keyboardType: TextInputType.multiline, // Supports multi-line input
            textInputAction:
                TextInputAction.newline, // Pressing Enter will add a new line
            decoration: const InputDecoration(
              hintText: 'Enter your recipe here...',
            ),
          ),
        ),
        actions: [
          // Create button
          MaterialButton(
            textColor: Colors.white,
            onPressed: () async {
              if (textController.text.isNotEmpty) {
                await context.read<database>().addRecipe(widget.serial!,
                    textController.text, widget.type!, widget.dish!);
                Navigator.pop(context);
                readRecipe(widget.dish!, widget.type!, widget.serial!);
                textController.clear();
              }
            },
            child: Text(
              'Create',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //read notes
  void readRecipe(String dish, String type, String serial) {
    context.read<database>().fetchRecipe(serial);
  }

  //update note
  void updateRecipe(Recipe name, String rec) async {
    //pre-fill the current note text into our controller
    final response = await Supabase.instance.client
        .from('recipes')
        .select('id') // Specify the field to fetch
        .eq('name', rec); // Filter by serial

// Convert the response to a list of maps
    final data = List<Map<String, dynamic>>.from(response);

// Clear the previous data if necessary

// Store the id in a string
    int recipeId = data.isNotEmpty
        ? data[0]['id']
        : ''; // Store the first id or an empty string if no data

// Optionally, you can print the id to verify
    print(recipeId);

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
                        await context.read<database>().updateRecipe(
                            widget.serial!,
                            recipeId,
                            textController.text,
                            widget.type!,
                            widget.dish!);
                        //clear the controller
                        textController.clear();
                        readRecipe(widget.dish!, widget.type!, widget.serial!);

                        //pop dialog box
                        Navigator.pop(context);
                      },
                      child: Text('Update',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .inversePrimary)))
                ]));
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
        title: const Text('Add Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Enter title',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: 'www.youtube.com',
              ),
            ),
          ],
        ),
        actions: [
          // Create button
          MaterialButton(
            textColor: Colors.white,
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
            child: Text(
              'Create',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
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

  void updateLink() {
    TextEditingController titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Enter title',
              ),
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 8),
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: 'www.youtube.com',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
        actions: [
          // Update button
          MaterialButton(
            textColor: Colors.white,
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
            child: Text(
              'Add',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
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

  @override
  Widget build(BuildContext context) {
    // note database
    final noteDatabase = context.watch<database>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Adjust sizes dynamically
    final iconSize =
        screenWidth * 0.08; // Adjust icon size based on screen width
    final titleFontSize = screenWidth * 0.07;
    // current notes
    List<Ingredients> currentNotes = noteDatabase.currentIng;
    List<Recipe> currentRecipe = noteDatabase.currentRecipe;
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        backgroundColor: Colors.blue.shade50,
        appBar: PreferredSize(
          preferredSize: MediaQuery.of(context).size.width > 600
              ? const Size.fromHeight(140.0)
              : const Size.fromHeight(104.0),
          child: AppBar(
            toolbarHeight: MediaQuery.of(context).size.width > 600
                ? 200
                : 120, // Adjust height based on screen width
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Theme.of(context).colorScheme.inversePrimary,
            leading: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.width > 600 ? 20.0 : 15.0,
                left: 10,
              ),
              child: IconButton(
                icon: Icon(
                  FontAwesomeIcons.arrowLeft,
                  size: MediaQuery.of(context).size.width > 600 ? 40 : iconSize,
                ),
                onPressed: () {
                  Navigator.pop(context); // Navigate back when pressed
                },
              ),
            ),
            title: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.width > 600 ? 20.0 : 40.0,
              ),
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
                            widget.dish != null && widget.dish!.length > 10
                                ? '${widget.dish!.substring(0, 10)}...'
                                : widget.dish ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: MediaQuery.of(context).size.width > 600
                                  ? 50
                                  : titleFontSize,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
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
                        IconButton(
                          key: _add,
                          onPressed: () => add(selectedTabIndex),
                          icon: const Icon(
                            Icons.add,
                            size: 35,
                          ),
                          tooltip: 'Add item',
                        ),

                        // Link button
                        GestureDetector(
                          key: _link,
                          onTap: () {
                            if (fetchedlink == null) {
                              createLink();
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
                          onLongPress: updateLink,
                          child: const Icon(
                            Icons.link,
                            size: 40,
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
                fontSize: MediaQuery.of(context).size.width > 600
                    ? 25.0
                    : MediaQuery.of(context).size.width * 0.04,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              unselectedLabelStyle: GoogleFonts.montserrat(
                fontSize: MediaQuery.of(context).size.width > 600
                    ? 25.0
                    : MediaQuery.of(context).size.width * 0.04,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              indicatorColor: Theme.of(context).colorScheme.inversePrimary,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Calculator : ",
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width > 600
                                ? 20
                                : 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black38,
                          ),
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            hint: Row(
                              children: [
                                Icon(
                                  Icons.list,
                                  size: MediaQuery.of(context).size.width > 600
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
                                      fontSize:
                                          MediaQuery.of(context).size.width >
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
                                .map((String item) => DropdownMenuItem<String>(
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
                              padding:
                                  const EdgeInsets.only(left: 14, right: 14),
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
                                thickness: MaterialStateProperty.all<double>(6),
                                thumbVisibility:
                                    MaterialStateProperty.all<bool>(true),
                              ),
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              height: 40,
                              padding: EdgeInsets.only(left: 14, right: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          ) // Show loading indicator
                        : currentNotes.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 300.0),
                                  child: Text('Add ingredients using +'),
                                ), // Show this if list is empty
                              )
                            : Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width >
                                                    600
                                                ? 10
                                                : 0,
                                        right: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (MediaQuery.of(context).size.width >
                                            600) ...[
                                          Text(
                                            "Ingredient",
                                            style: GoogleFonts.montserrat(
                                              fontSize: 25.0,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .inversePrimary,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 100.0),
                                            child: Text("Quantity",
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 25.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .inversePrimary,
                                                )),
                                          ),
                                          Text("Calculated Quantity",
                                              style: GoogleFonts.montserrat(
                                                fontSize: 25.0,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .inversePrimary,
                                              )),
                                        ] else ...[
                                          // Ingredient Text
                                          Flexible(
                                            flex: 1,
                                            child: Text(
                                              "Ingredient",
                                              style: GoogleFonts.montserrat(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.04, // Responsive font size
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .inversePrimary,
                                              ),
                                            ),
                                          ),
                                          // Quantity Text
                                          Flexible(
                                            flex: 0,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.155), // Dynamic padding
                                              child: Text(
                                                "Qty",
                                                style: GoogleFonts.montserrat(
                                                  fontSize: MediaQuery.of(
                                                              context)
                                                          .size
                                                          .width *
                                                      0.04, // Responsive font size
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .inversePrimary,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Calculated Quantity Text
                                          Flexible(
                                            flex: 2,
                                            child: Text(
                                              "Calculated Qty",
                                              style: GoogleFonts.montserrat(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.04, // Responsive font size
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .inversePrimary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
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
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 300.0),
                            child: Text('Add recipe using +'),
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

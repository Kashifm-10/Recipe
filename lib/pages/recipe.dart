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
import 'package:recipe/models/brin_db.dart';
import 'package:recipe/collections/ingredients.dart';
import 'package:recipe/models/breakfast_tile.dart';
import 'package:recipe/models/ingredientList.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:recipe/models/isar_instance.dart';
import 'package:recipe/models/recipeList.dart';
import 'package:linkable/linkable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class recipe extends StatefulWidget {
  recipe(
      {super.key,
      required this.serial,
      required this.type,
      required this.dish});
  String? serial;
  String? type;
  String? dish;

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

  @override
  void initState() {
    super.initState();
    _createTutorial();
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
                                            int linkId = fetchedLinksId[index];
                                            await deleteLink(linkId);

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
    // Additional TextEditingController for the second input
    TextEditingController quantityController = TextEditingController();
    TextEditingController textController = TextEditingController();

    // Dropdown selection options
    String? selectedUnit;
    List<String> unitOptions = ['gm', 'Kg', 'ltr', 'Cup(s)', 'Spoon(s)'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('Add Ingredient'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // First text field for the ingredient name
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: 'Ingredient',
                  ),
                ),
                const SizedBox(height: 10),

                // Second text field for quantity
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    hintText: 'Quantity',
                  ),
                  keyboardType:
                      TextInputType.number, // Only allow numeric input
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
                    // Assuming addIng method is modified to accept the quantity and unit
                    await context.read<database>().addIng(
                          widget.serial!,
                          textController.text,
                          widget.type!,
                          widget.dish!,
                          quantityController.text,
                          selectedUnit!,
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
                      color: Theme.of(context).colorScheme.inversePrimary),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  //read notes
  void readIngeadints(String dish, String? serial) {
    context.read<database>().fetchIng(dish, serial);
  }

  //update note
  void updateIng(Ingredients ingredient) async {
    // Create controllers for the text fields and unit selection
    TextEditingController textController =
        TextEditingController(text: ingredient.name);
    TextEditingController quantityController =
        TextEditingController(text: ingredient.quantity);
    String? selectedUnit =
        ingredient.uom; // Assuming Ingredients has a unit field

    // Dropdown selection options
    List<String> unitOptions = ['gm', 'kg', 'ltr', 'cups'];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('Edit Ingredient'),
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
                  keyboardType:
                      TextInputType.number, // Only allow numeric input
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
              // Update button
              MaterialButton(
                textColor: Colors.white,
                onPressed: () async {
                  if (textController.text.isNotEmpty &&
                      quantityController.text.isNotEmpty &&
                      selectedUnit != null) {
                    // Update the ingredient in the database
                    await context.read<database>().updateIng(
                          ingredient.id,
                          textController.text,
                          widget.type!,
                          quantityController.text,
                          selectedUnit!,
                        );

                    // Clear the controllers and refresh the list
                    textController.clear();
                    quantityController.clear();
                    readIngeadints(widget.dish!, widget.serial!);

                    // Pop the dialog box
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
  void deleteIng(int id) async {
    await context.read<database>().deleteIng(id, widget.type!);
    readIngeadints(widget.dish!, widget.serial!);
  }

  void createRecipe() {
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
  }

  //read notes
  void readRecipe(String dish, String type, String serial) {
    context.read<database>().fetchRecipe(serial);
  }

  //update note
  void updateRecipe(Recipe name) async {
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
                        await context.read<database>().updateRecipe(
                            widget.serial!,
                            name.id,
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
  void deleteRecipe(int id) async {
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
        title: const Text('Update Link'),
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
              'Update',
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
  Future<void> deleteLink(int id) async {
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
    '0.5',
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

    // current notes
    List<Ingredients> currentNotes = noteDatabase.currentIng;
    List<Recipe> currentRecipe = noteDatabase.currentRecipe;
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        backgroundColor: Colors.blue.shade50,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(
              140.0), // Increase the height to fit the content
          child: AppBar(
              toolbarHeight: 200,
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.dish!,
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 50,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0, right: 20),
                          child: IconButton(
                            key: _add,
                            onPressed: () {
                              add(selectedTabIndex);
                            },
                            icon: const Icon(
                              Icons.add,
                              size: 35,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, right: 30),
                          child: GestureDetector(
                            key: _link,
                            onTap: () {
                              if (fetchedlink == null) {
                                createLink();
                              } else {
                                final List<int> fetchedLinksId =
                                    fetchedlinkid is List<int>
                                        ? fetchedlinkid as List<int>
                                        : [fetchedlinkid as int];
                                // Safely cast fetchedlink to List<String> or wrap it in a list if it's a single string
                                final List<String> fetchedLinks = fetchedlink
                                        is List<String>
                                    ? fetchedlink as List<String>
                                    : [
                                        fetchedlink as String
                                      ]; // Forcefully cast to String if it's a single link

                                final List<String> fetchedlinknames =
                                    fetchedTitle is List<String>
                                        ? fetchedTitle as List<String>
                                        : [fetchedTitle as String];

                                _launchUrl(fetchedLinks, fetchedLinksId,
                                    fetchedlinknames); // Pass the list of links
                              }
                            },
                            onLongPress: updateLink,
                            child: const Icon(
                              Icons.link,
                              size: 40,
                            ),
                          ),
                        ),
                      ],
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
                labelStyle: GoogleFonts.dmSerifDisplay(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                unselectedLabelStyle: GoogleFonts.dmSerifDisplay(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
                indicatorColor: Theme.of(context)
                    .colorScheme
                    .inversePrimary, // Set the color of the indicator below the tabs
              )),
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
                        const EdgeInsets.only(top: 10, right: 40.0, bottom: 10),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        hint: const Row(
                          children: [
                            Icon(
                              Icons.list,
                              size: 16,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Expanded(
                              child: Text(
                                '1',
                                style: TextStyle(
                                  fontSize: 14,
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
                                    style: const TextStyle(
                                      fontSize: 14,
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
                          height: 50,
                          width: 70,
                          padding: const EdgeInsets.only(left: 14, right: 14),
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
                          width: 70,
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
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: ListView.builder(
                      physics:
                          const NeverScrollableScrollPhysics(), // Disable individual scrolling
                      shrinkWrap:
                          true, // Ensures the ListView takes minimal height
                      itemCount: currentNotes.length,
                      itemBuilder: (context, index) {
                        final note = currentNotes[index];
                        return ingredientList(
                          count: double.parse(selectedValue!),
                          dish: widget.dish,
                          type: widget.type!,
                          text: note.name!,
                          quantity: int.parse(note.quantity!),
                          uom: note.uom,
                          onEditPressed: () => updateIng(note),
                          onDeletePressed: () => deleteIng(note.id),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Instructions Tab

            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /*  IconButton(
                    onPressed: createRecipe,
                    icon: Icon(
                      Icons.add,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ), */
                  ListView.builder(
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable individual scrolling
                    shrinkWrap:
                        true, // Ensures the ListView takes minimal height
                    itemCount: currentRecipe.length,
                    itemBuilder: (context, index) {
                      final note = currentRecipe[index];
                      return recipeList(
                        dish: widget.dish,
                        type: widget.type!,
                        text: note.name!,
                        onEditPressed: () => updateRecipe(note),
                        onDeletePressed: () => deleteRecipe(note.id),
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

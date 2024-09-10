import 'package:flutter/material.dart';
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
import 'package:url_launcher/url_launcher.dart';

class recipe extends StatefulWidget {
  recipe({super.key, required this.type, required this.dish});
  String? type;
  String? dish;

  @override
  State<recipe> createState() => _recipeState();
}

final isar = IsarInstance().isar;

class _recipeState extends State<recipe> {
  //text controller to access what the user typed
  TextEditingController textController = TextEditingController();
  List<Map<String, String>> linkData = [];

  String? dish;
  String? type;
  String? fetchedlink;

  @override
  void initState() {
    super.initState();
    // on app startup, fetch the existing notes
    readIngeadints(widget.dish!);
    readRecipe(widget.dish!, widget.type!);
    dish = widget.dish;
    type = widget.type;
    readLink(widget.dish!, widget.type!);
  }

  Future<void> _launchUrl() async {
    final Uri _url = Uri.parse(fetchedlink!);
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

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
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Add Ingredient'),
                content: TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: 'Ingredient',
                  ),
                ),
                actions: [
                  //create button
                  MaterialButton(
                      textColor: Colors.white,
                      onPressed: () async {
                        if (textController.text.isNotEmpty) {
                          await context.read<database>().addIng(
                              textController.text, widget.type!, widget.dish!);
                          Navigator.pop(context);
                          readIngeadints(widget.dish!);
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
  void readIngeadints(String dish) {
    context.read<database>().fetchIng(dish);
  }

  //update note
  void updateIng(Ingredients name) async {
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
                        await context.read<database>().updateIng(
                            name.id, textController.text, widget.type!);
                        //clear the controller
                        textController.clear();
                        readIngeadints(widget.dish!);
                        //pop dialog box
                        Navigator.pop(context);
                      },
                      child: Text('Update',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .inversePrimary)))
                ]));
    readIngeadints(widget.dish!);
  }

  //delete a note
  void deleteIng(int id) async {
    await context.read<database>().deleteIng(id, widget.type!);
    readIngeadints(widget.dish!);
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
                              textController.text, widget.type!, widget.dish!);
                          Navigator.pop(context);
                          readRecipe(widget.dish!, widget.type!);
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
  void readRecipe(String dish, String type) {
    context.read<database>().fetchRecipe(dish, type);
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
                        await context.read<database>().updateRecipe(name.id,
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
  }

  //delete a note
  void deleteRecipe(int id) async {
    await context.read<database>().deleteRecipe(id, widget.type!, widget.dish!);
    readRecipe(widget.dish!, widget.type!);
  }

  void createLink() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Add Link'),
                content: TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: 'www.youtube.com',
                  ),
                ),
                actions: [
                  //create button
                  MaterialButton(
                      textColor: Colors.white,
                      onPressed: () async {
                        if (textController.text.isNotEmpty) {
                          await context.read<database>().addLink(
                              textController.text, widget.type!, widget.dish!);
                          Navigator.pop(context);
                          readRecipe(widget.dish!, widget.type!);
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
  void readLink(String dish, String type) async {
    // Await the result of fetchLink to get the actual string
    String? link = await context.read<database>().fetchLink(dish, type);
    fetchedlink = link;
    // Handle the link (e.g., print it, use it, etc.)
    //print(link);
  }

  void updateLink() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Link'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'www.youtube.com', hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          //create button
          MaterialButton(
            textColor: Colors.white,
            onPressed: () async {
              if (textController.text.isNotEmpty) {
                await context
                    .read<database>()
                    .addLink(textController.text, widget.type!, widget.dish!);
                Navigator.pop(context);
                readRecipe(widget.dish!, widget.type!);
                textController.clear();
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
  void deleteLink(int id) async {
    await context.read<database>().deleteLink(id, widget.type!, widget.dish!);
    readRecipe(widget.dish!, widget.type!);
  }

  SpeedDial floatingActionButtonMenu(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      children: [
        SpeedDialChild(
          child: Icon(Icons.add),
          label: 'add Ingredient',
          onTap: createIngredient,
        ),
        SpeedDialChild(
          child: Icon(Icons.add),
          label: 'add Recipe',
          onTap: () {
            createRecipe();
            // Add edit action here
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.delete),
          label: 'Delete Note',
          onTap: () {
            // Add delete action here
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    //note database
    final noteDatabase = context.watch<database>();

    //current notes
    List<Ingredients> currentNotes = noteDatabase.currentIng;
    List<Recipe> currentRecipe = noteDatabase.currentRecipe;

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
  elevation: 0,
  backgroundColor: Colors.transparent,
  foregroundColor: Theme.of(context).colorScheme.inversePrimary,
  leading: IconButton(
    icon: Icon(Icons.arrow_back),
    onPressed: () {
      Navigator.pop(context); // Navigate back when pressed
    },
  ),
),

      //drawer: const Drawer(),
      /* floatingActionButton: FloatingActionButton(
        onPressed: createNote,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add,
            color: Theme.of(context).colorScheme.inversePrimary),
      ), */
      // floatingActionButton: floatingActionButtonMenu(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Text(
                  'Recipe',
                  style: GoogleFonts.dmSerifDisplay(
                      fontSize: 60,
                      color: Theme.of(context).colorScheme.inversePrimary),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 30.0),
                child: GestureDetector(
                  onTap: fetchedlink == null ? createLink : _launchUrl,
                  onLongPress: updateLink,
                  child: Icon(Icons.link),
                ),
              ),
            ],
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 30),
                      child: Text(
                        "Ingerdients",
                        style: GoogleFonts.dmSerifDisplay(
                            fontSize: 30,
                            color:
                                Theme.of(context).colorScheme.inversePrimary),
                      ),
                    ),
                    IconButton(
                        onPressed: createIngredient,
                        icon: Icon(Icons.add,
                            color:
                                Theme.of(context).colorScheme.inversePrimary))
                  ],
                ),
                ListView.builder(
                  physics:
                      NeverScrollableScrollPhysics(), // Disable individual scrolling
                  shrinkWrap: true, // Ensures the ListView takes minimal height
                  itemCount: currentNotes.length,
                  itemBuilder: (context, index) {
                    final note = currentNotes[index];
                    return ingredientList(
                      dish: widget.dish,
                      type: widget.type!,
                      text: note.name!,
                      onEditPressed: () => updateIng(note),
                      onDeletePressed: () => deleteIng(note.id),
                    );
                  },
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 30),
                      child: Text(
                        "Instructions",
                        style: GoogleFonts.dmSerifDisplay(
                            fontSize: 30,
                            color:
                                Theme.of(context).colorScheme.inversePrimary),
                      ),
                    ),
                    IconButton(
                        onPressed: createRecipe,
                        icon: Icon(Icons.add,
                            color:
                                Theme.of(context).colorScheme.inversePrimary))
                  ],
                ),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
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
          )
        ],
      ),
    );
  }
}

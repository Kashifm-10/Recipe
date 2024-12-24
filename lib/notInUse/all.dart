/* import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:recipe/collections/names.dart';
import 'package:recipe/models/br_database.dart';
import 'package:recipe/models/breakfast_tile.dart';

class all extends StatefulWidget {
   all({super.key, required this.type});
String? type;
  @override
  State<all> createState() => _allState();
}

class _allState extends State<all> {
  //text controller to access what the user typed
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // on app startup, fetch the existing notes
    readNotes(widget.type!);
  }

  //function to create a note
  void createNote() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.primary,
                content: TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(),
                    hintText: 'Add new note',
                  ),
                ),
                actions: [
                  //create button
                  MaterialButton(
                      textColor: Colors.white,
                      onPressed: () {
                        if (textController.text.isNotEmpty) {
                          /* context
                              .read<BrDatabase>()
                              .addName(textController.text); */
                          Navigator.pop(context);
                          textController.clear();
                        }
                      },
                      child: Text('Create',
                          style: GoogleFonts.poppins(
                              color: Theme.of(context)
                                  .colorScheme
                                  .inversePrimary)))
                ]));
  }

  //read notes
  void readNotes(String type) {
    context.read<BrDatabase>().fetchNotes(type);
  }

  //update note
  void updateNote(Dish name, String type) {
    //pre-fill the current note text into our controller
    textController.text = name.name!;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Update Dish'),
                content: TextField(
                  controller: textController,
                  decoration: const InputDecoration(),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                actions: [
                  MaterialButton(
                      onPressed: () {
                        //update note in db
                        context
                            .read<BrDatabase>()
                            .updateNote(name.id, textController.text, type);
                        //clear the controller
                        textController.clear();
                        //pop dialog box
                        Navigator.pop(context);
                      },
                      child: Text('Update',
                          style: GoogleFonts.poppins(
                              color: Theme.of(context)
                                  .colorScheme
                                  .inversePrimary)))
                ]));
  }

  //delete a note
  void deleteNote(int id, String type) {
    context.read<BrDatabase>().deleteNote(id, widget.type!);
  }

  @override
  Widget build(BuildContext context) {
    //note database
    final noteDatabase = context.watch<BrDatabase>();

    //current notes
    List<Dish> currentNotes = noteDatabase.currentNames;
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Theme.of(context).colorScheme.inversePrimary),
        drawer: const Drawer(),
        floatingActionButton: FloatingActionButton(
            onPressed: createNote,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(Icons.add,
                color: Theme.of(context).colorScheme.inversePrimary)),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Text('Notes',
                  style: GoogleFonts.dmSerifDisplay(
                      fontSize: 48,
                      color: Theme.of(context).colorScheme.inversePrimary))),
          Expanded(
              child: ListView.builder(
                  itemCount: currentNotes.length,
                  itemBuilder: (context, index) {
                    // get individual note
                    final note = currentNotes[index];
                    //list tile ui
                    return DishTile(
                      text: note.name!,
                      onEditPressed: () => updateNote(note, widget.type!),
                      onDeletePressed: () => deleteNote(note.id, widget.type!),
                    );
                  }))
        ]));
  }
}
 */
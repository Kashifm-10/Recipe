/* import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recipe/Breakfast/collections/brname.dart';
import 'package:recipe/Breakfast/collections/inside/bringredients.dart';

class BrinDatabase extends ChangeNotifier {
  static late Isar isar;

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([BringredientsSchema], directory: dir.path);
  }

  final List<Bringredients> currentNames = [];
  Future<void> addName(String textFromUser) async {
    //create a new note object
    final newName = Bringredients()..name = textFromUser;

    //save to db
    await isar.writeTxn(() => isar.bringredients.put(newName));

    //re-read from db
    fetchNotes();
  }

  //READ
  Future<void> fetchNotes() async {
    List<Bringredients> fetchedNotes =
        await isar.bringredients.where().findAll();
    currentNames.clear();
    currentNames.addAll(fetchedNotes);
    notifyListeners();
  }

  //UPDATE
  Future<void> updateNote(int id, String newText) async {
    final existingNote = await isar.bringredients.get(id);
    if (existingNote != null) {
      existingNote.name = newText;
      await isar.writeTxn(() => isar.bringredients.put(existingNote));
      await fetchNotes();
    }
  }

  //DELETE
  Future<void> deleteNote(int id) async {
    await isar.writeTxn(() => isar.bringredients.delete(id));
    await fetchNotes();
  }
}
 */
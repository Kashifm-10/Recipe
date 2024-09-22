import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recipe/collections/homeTitle.dart';
import 'package:recipe/collections/links.dart';
import 'package:recipe/collections/names.dart';
import 'package:recipe/collections/ingredients.dart';
import 'package:recipe/collections/recipe.dart';

class database extends ChangeNotifier {
  static late Isar isar;

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar =
        await Isar.open([DishSchema, IngredientsSchema, RecipeSchema, LinksSchema, TitleSchema], directory: dir.path);
  }

  final List<Dish> currentNames = [];
  final List<Title> currentTitles = [];


Future<void> addType(String serial, String textFromUser, String type, String duration, String category, String date, String time) async {
    //create a new note object
    final newDish = Dish(name: textFromUser, duration: duration , category: category, date: date, time: time, serial: serial)..type = type;
    

    //save to db
    await isar.writeTxn(() => isar.dishs.put(newDish));

    //re-read from db
    fetchNotes(type);
  }
 /*  Future<void> addName(String textFromUser) async {
    //create a new note object
    final newName = Dish(name: '')..name = textFromUser;
    

    //save to db
    await isar.writeTxn(() => isar.dishs.put(newName));

    //re-read from db
    fetchNotes();
  } */

  //READ
  Future<void> fetchNotes(String type) async {
    List<Dish> fetchedNotes = await isar.dishs.where() .filter().typeEqualTo(type).findAll();
    currentNames.clear();
    currentNames.addAll(fetchedNotes);
    notifyListeners();
  }

  //UPDATE
  Future<void> updateNote(int id, String newText, String type, String duration, String category, String date, String time) async {
    final existingNote = await isar.dishs.get(id);
    if (existingNote != null) {
      existingNote.name = newText;
      existingNote.duration = duration;
      existingNote.category= category;
      existingNote.date = date;
      existingNote.time = time;
      await isar.writeTxn(() => isar.dishs.put(existingNote));
      await fetchNotes(type);
    }
  }

  //DELETE
  Future<void> deleteNote(int id, String type) async {
    await isar.writeTxn(() => isar.dishs.delete(id));
    await fetchNotes(type);
  }

  final List<Ingredients> currentIng = [];
  final List<Recipe> currentRecipe = [];
  final List<Links> currentLink = [];
  final List<Title> currentTitle = [];
  Future<void> addIng(String? serial, String textFromUser, String type, String dish, String quantity, String uom) async {
    //create a new note object
    final newIng = Ingredients(name: textFromUser, quantity: quantity, type: type, uom: uom, serial: serial)..dish = dish;

    //save to db
    await isar.writeTxn(() => isar.ingredients.put(newIng));

    //re-read from db
    fetchNotes(type);
  }

  //READ
  Future<void> fetchIng(String dish, String? serial) async {
    List<Ingredients> fetchedIng = await isar.ingredients.where().filter().serialEqualTo(serial).findAll();
    currentIng.clear();
    currentIng.addAll(fetchedIng);
    notifyListeners();
  }

  //UPDATE
  Future<void> updateIng(int id, String newText, String type, String quantity, String uom) async {
    final existingNote = await isar.ingredients.get(id);
    if (existingNote != null) {
      existingNote.name = newText;
      existingNote.quantity = quantity;
      existingNote.uom = uom;
      await isar.writeTxn(() => isar.ingredients.put(existingNote));
      await fetchNotes(type);
    }
  }

  //DELETE
  Future<void> deleteIng(int id, String type) async {
    await isar.writeTxn(() => isar.ingredients.delete(id));
    await fetchNotes(type);
  }

Future<void> addRecipe(String serial, String textFromUser, String type, String dish) async {
    //create a new note object
    final newName = Recipe(name: textFromUser, type: type, serial: serial)..dish = dish;

    //save to db
    await isar.writeTxn(() => isar.recipes.put(newName));

    //re-read from db
    fetchRecipe( serial);
  }


Future<void> fetchRecipe(String serial) async {
    List<Recipe> fetchedRecipe = await isar.recipes.where().filter().serialEqualTo(serial).findAll();
    currentRecipe.clear();
    currentRecipe.addAll(fetchedRecipe);
    notifyListeners();
  }

  //UPDATE
  Future<void> updateRecipe(String serial, int id, String newText, String type, String dish) async {
    final existingRecipe = await isar.recipes.get(id);
    if (existingRecipe != null) {
      existingRecipe.name = newText;
      await isar.writeTxn(() => isar.recipes.put(existingRecipe));
      await fetchRecipe(serial);
    }
  }

  //DELETE
  Future<void> deleteRecipe(String serial, int id, String type, String dish) async {
    await isar.writeTxn(() => isar.recipes.delete(id));
    await fetchRecipe(serial);
  }


  Future<void> addLink(String linkName, String textFromUser, String serial, String type, String dish) async {
    //create a new note object
    final newName = Links(link: textFromUser, type: type, serial: serial, linkName: linkName)..dish = dish;

    //save to db
    await isar.writeTxn(() => isar.links.put(newName));

    //re-read from db
    fetchLink(serial);
  }


Future<List<Links>> fetchLink(String serial) async {
  List<Links> fetchedLink = await isar.links.where().filter().serialEqualTo(serial).findAll();
  currentLink.clear();
  currentLink.addAll(fetchedLink);
  notifyListeners();
  return fetchedLink.toList();
  
  // Assuming you want to return a specific string from the fetchedLink list
 /*  if (fetchedLink.isNotEmpty) {
    return fetchedLink.last.link; // Replace `link` with the actual property you want to return
  } */
  
 /*  return null; */ // Return null if no link is found
}

  //UPDATE
  Future<void> updateLink(int id, String newText, String serial) async {
    final existingLink = await isar.links.get(id);
    if (existingLink != null) {
      existingLink.link = newText;
      await isar.writeTxn(() => isar.links.put(existingLink));
      await fetchLink(serial);
    }
  }

  //DELETE
  Future<void> deleteLink(int id, String serial) async {
    await isar.writeTxn(() => isar.links.delete(id));
    await fetchLink(serial);
  }


  Future<void> fetchTitles() async {
  try {
    // Access the Isar instance
    

    // Fetch the titles from the Isar database
    List<Title> fetchedTitles = await isar.titles.where().findAll();

    // Clear any existing titles and add the fetched ones
    currentTitles.clear();
    currentTitles.addAll(fetchedTitles);

    // Notify listeners if using a state management solution
  } catch (e) {
    // Handle errors (you can log the error or handle it based on your needs)
    print('Error fetching titles: $e');
  }
}

Future<void> addTitle(String title, String type) async {
  // Fetch the existing title with the same type
  final existingTitle = await isar.titles.where().filter().typeEqualTo(type).findFirst();

  // Create a new Title instance with the provided title and type
  final newName = Title(title: title, type: type);

  await isar.writeTxn(() async {
    if (existingTitle != null) {
      // Remove the existing title
      await isar.titles.delete(existingTitle.id);
    }
    // Add the new title
    await isar.titles.put(newName);
  });

  // Fetch or refresh the titles
  fetchTitle(title, type);
}
 Future<List<Title>> fetchTitlesByType(String type) async {
    return await isar.titles.where().filter().typeEqualTo(type).findAll();
  }

Future<void> fetchTitle(String title, String type) async {
    List<Title> fetchedTitle = await isar.titles.where().filter().titleEqualTo(title).and().typeEqualTo(type).findAll();
    currentTitle.clear();
    currentTitle.addAll(fetchedTitle);
    notifyListeners();
  }

  Future<void> fetchOneTitle( String type) async {
    List<Title> fetchedTitle = await isar.titles.where().filter().typeEqualTo(type).findAll();
    currentTitle.clear();
    currentTitle.addAll(fetchedTitle);
    notifyListeners();
  }

  Future<bool> titleExists(String title, String type) async {
    final query = await isar.titles.where().filter().typeEqualTo(type).titleEqualTo(title).findAll();
    return query.isNotEmpty;
  }

  // Method to add a new title if it doesn't already exist
  Future<void> addTitleIfNotExists(String title, String type) async {
    final exists = await titleExists(title, type);
    if (!exists) {
      await isar.writeTxn(() async {
        await isar.titles.put(Title(title: title)..type = type);
      });
    }
  }
Future<List<Map<String, String>>> fetchtitlesFromIsar(String? type) async {
  List<Map<String, String>> title = [];

  final titles = await isar.titles.where().filter().typeEqualTo(type).findAll();

  title.addAll(titles.map((deal) {
    return {
      'title': deal.title,
    };
  }).toList());
  
  return title;
}


 
}




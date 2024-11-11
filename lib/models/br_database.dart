import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recipe/collections/homeTitle.dart';
import 'package:recipe/collections/links.dart';
import 'package:recipe/collections/names.dart';
import 'package:recipe/collections/ingredients.dart';
import 'package:recipe/collections/recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class database extends ChangeNotifier {
  static late Isar isar;

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
        [DishSchema, IngredientsSchema, RecipeSchema, LinksSchema, TitleSchema],
        directory: dir.path);
  }

  final List<Title> currentTitles = [];

/*   Future<void> addDish(String serial, String textFromUser, String type,
      String duration, String category, String date, String time) async {
    //create a new note object
    final newDish = Dish(
        name: textFromUser,
        duration: duration,
        category: category,
        date: date,
        time: time,
        serial: serial)
      ..type = type;

    //save to db
    await isar.writeTxn(() => isar.dishs.put(newDish));

    //re-read from db
    fetchNotes(type);
  } */

  final List<Ingredients> currentIng = [];
  final List<Recipe> currentRecipe = [];
  final List<Links> currentLink = [];
  final List<Title> currentTitle = [];
  /* Future<void> addIng(String? serial, String textFromUser, String type,
      String dish, String quantity, String uom) async {
    //create a new note object
    final newIng = Ingredients(
        name: textFromUser,
        quantity: quantity,
        type: type,
        uom: uom,
        serial: serial)
      ..dish = dish;

    //save to db
    await isar.writeTxn(() => isar.ingredients.put(newIng));

    //re-read from db
    fetchDishes(type);
  } */

  //READ
  /* Future<void> fetchIng(String dish, String? serial) async {
    List<Ingredients> fetchedIng =
        await isar.ingredients.where().filter().serialEqualTo(serial).findAll();
    currentIng.clear();
    currentIng.addAll(fetchedIng);
    notifyListeners();
  } */

  //UPDATE
  /* Future<void> updateIng(
      int id, String newText, String type, String quantity, String uom) async {
    final existingNote = await isar.ingredients.get(id);
    if (existingNote != null) {
      existingNote.name = newText;
      existingNote.quantity = quantity;
      existingNote.uom = uom;
      await isar.writeTxn(() => isar.ingredients.put(existingNote));
      await fetchDishes(type);
    }
  } */

  //DELETE
  /* Future<void> deleteIng(int id, String type) async {
    await isar.writeTxn(() => isar.ingredients.delete(id));
    await fetchDishes(type);
  } */

  /* Future<void> addLink(String linkName, String textFromUser, String serial,
      String type, String dish) async {
    //create a new note object
    final newName = Links(
        link: textFromUser, type: type, serial: serial, linkName: linkName)
      ..dish = dish;

    //save to db
    await isar.writeTxn(() => isar.links.put(newName));

    //re-read from db
    fetchLink(serial);
  } */

  /* Future<List<Links>> fetchLink(String serial) async {
    List<Links> fetchedLink =
        await isar.links.where().filter().serialEqualTo(serial).findAll();
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
 */
  //UPDATE
  /*  Future<void> updateLink(int id, String newText, String serial) async {
    final existingLink = await isar.links.get(id);
    if (existingLink != null) {
      existingLink.link = newText;
      await isar.writeTxn(() => isar.links.put(existingLink));
      await fetchLink(serial);
    }
  } */

  //DELETE
  /* Future<void> deleteLink(int id, String serial) async {
    await isar.writeTxn(() => isar.links.delete(id));
    await fetchLink(serial);
  } */
/* 
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
  } */

  /*  Future<void> addTitle(String title, String type) async {
    // Fetch the existing title with the same type
    final existingTitle =
        await isar.titles.where().filter().typeEqualTo(type).findFirst();

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
  } */

  /*  Future<List<Title>> fetchTitlesByType(String type) async {
    return await isar.titles.where().filter().typeEqualTo(type).findAll();
  }
 */
  /*  Future<void> fetchTitle(String title, String type) async {
    List<Title> fetchedTitle = await isar.titles
        .where()
        .filter()
        .titleEqualTo(title)
        .and()
        .typeEqualTo(type)
        .findAll();
    currentTitle.clear();
    currentTitle.addAll(fetchedTitle);
    notifyListeners();
  } */

  /* Future<void> fetchOneTitle(String type) async {
    List<Title> fetchedTitle =
        await isar.titles.where().filter().typeEqualTo(type).findAll();
    currentTitle.clear();
    currentTitle.addAll(fetchedTitle);
    notifyListeners();
  } */

/*   Future<bool> titleExists(String title, String type) async {
    final query = await isar.titles
        .where()
        .filter()
        .typeEqualTo(type)
        .titleEqualTo(title)
        .findAll();
    return query.isNotEmpty;
  } */

  // Method to add a new title if it doesn't already exist
  /* Future<void> addTitleIfNotExists(String title, String type) async {
    final exists = await titleExists(title, type);
    if (!exists) {
      await isar.writeTxn(() async {
        await isar.titles.put(Title(title: title)..type = type);
      });
    }
  } */

  /*  Future<List<Map<String, String>>> fetchtitlesFromIsar(String? type) async {
    List<Map<String, String>> title = [];

    final titles =
        await isar.titles.where().filter().typeEqualTo(type).findAll();

    title.addAll(titles.map((deal) {
      return {
        'title': deal.title,
      };
    }).toList());

    return title;
  } */

//CONVERTED TO SUPABASE
//
//
//
//
//
//
//
//
//

  final List<Recipe> recipes = [];
  final List<Dish> dishes = [];
  final List<Dish> currentNames = [];
  Future<void> addDish(String serial, String textFromUser, String type,
      String duration, String category, String date, String time) async {
    final prefs = await SharedPreferences.getInstance();
    String? mail = prefs.getString('email');
    final newDish = {
      'name': textFromUser,
      'serial': serial,
      'type': type,
      'duration': duration,
      'category': category,
      'date': date,
      'time': time,
      'mail': mail,
    };

    final response =
        await Supabase.instance.client.from('dishes').insert(newDish);

    fetchDishes(type);
  }

  Future<void> fetchDishes(String type) async {
    final prefs = await SharedPreferences.getInstance();
    String? mail = prefs.getString('email');
    final response = await Supabase.instance.client
        .from('dishes')
        .select()
        .eq('type', type);
       //S .eq('mail', mail!);
    final data = List<Map<String, dynamic>>.from(response);

    dishes.clear();
    dishes.addAll(data.map((item) => Dish(
          name: item['name'],
          serial: item['serial'],
          type: item['type'],
          duration: item['duration'],
          category: item['category'],
          date: item['date'],
          time: item['time'],
        )));

    print(response);

    currentNames.clear();
    currentNames.addAll(dishes);
    notifyListeners();
  }

  //UPDATE
  Future<void> updateDish(int id, String newText, String type, String duration,
      String category, String date, String time) async {
    final existingNote = await isar.dishs.get(id);
    final updatedNote = {
      'name': newText,
      'duration': duration,
      'category': category,
      'date': date,
      'time': time,
    };

    final response = await Supabase.instance.client
        .from('dishes')
        .update(updatedNote)
        .eq('id', id);

    await fetchDishes(type);
  }

  //DELETE ALL RELATED TO DISH
  Future<void> deleteDish(int id, String type, String serial) async {
    final response =
        await Supabase.instance.client.from('dishes').delete().eq('id', id);
    await isar.writeTxn(() => isar.dishs.delete(id));
    deleteRecipesBySerial(serial);
    deleteIngredientsBySerial(serial);
    deleteLinksBySerial(serial);
    await fetchDishes(type);
  }

  Future<void> deleteRecipesBySerial(String serial) async {
    final response = await Supabase.instance.client
        .from('recipes')
        .delete()
        .eq('serial', serial);
/*     await fetchRecipe(serial);
 */
  }

  Future<void> deleteIngredientsBySerial(String serial) async {
    final response = await Supabase.instance.client
        .from('ingredients')
        .delete()
        .eq('serial', serial);
    /*  if (response.error != null) {
      print('Error deleting ingredients: ${response.error!.message}');
    } */
  }

  Future<void> deleteLinksBySerial(String serial) async {
    final response = await Supabase.instance.client
        .from('links')
        .delete()
        .eq('serial', serial);
    /*  if (response.error != null) {
      print('Error deleting link: ${response.error!.message}');
    } */
  }

  Future<void> addRecipe(
      String serial, String textFromUser, String type, String dish) async {
    final newRecipe = {
      'name': textFromUser,
      'serial': serial,
      'type': type,
      'dish': dish,
    };

    final response =
        await Supabase.instance.client.from('recipes').insert(newRecipe);

    //re-read from db
    fetchRecipe(serial);
  }

  Future<void> fetchRecipe(String serial) async {
    final response = await Supabase.instance.client
        .from('recipes')
        .select()
        .eq('serial', serial);
    final data = List<Map<String, dynamic>>.from(response);
    recipes.clear();
    recipes.addAll(data.map((item) => Recipe(
          name: item['name'],
          serial: item['serial'],
          type: item['type'],
        )));
    print(response);

    currentRecipe.clear();
    currentRecipe.addAll(recipes);
    notifyListeners();
  }

  //UPDATE
  Future<void> updateRecipe(
      String serial, int id, String newText, String type, String dish) async {
    final updatedRecipe = {
      'name': newText,
      'serial': serial,
      'type': type,
      'dish': dish,
    };

    final response = await Supabase.instance.client
        .from('recipes')
        .update(updatedRecipe)
        .eq('id', id);
    await fetchRecipe(serial);
  }

  //DELETE
  Future<void> deleteRecipe(
      String serial, int id, String type, String dish) async {
    final response =
        await Supabase.instance.client.from('recipes').delete().eq('id', id);
    await fetchRecipe(serial);
  }

  Future<void> addIngredient(String? serial, String textFromUser, String type,
      String dish, String quantity, String uom) async {
    final newIng = {
      'name': textFromUser,
      'serial': serial,
      'type': type,
      'dish': dish,
      'quantity': quantity,
      'uom': uom,
    };

    final response =
        await Supabase.instance.client.from('ingredients').insert(newIng);

    fetchIngredients(dish, serial);
  }

  Future<void> fetchIngredients(String dish, String? serial) async {
    // Fetch ingredients from Supabase using the serial as a filter
    final response = await Supabase.instance.client
        .from('ingredients')
        .select()
        .eq('serial', serial!);
    final data = List<Map<String, dynamic>>.from(response);

    currentIng.clear();
    currentIng.addAll(data.map((item) => Ingredients(
          name: item['name'],
          serial: item['serial'],
          quantity: item['quantity'],
          uom: item['uom'],
        )));

    print(data);

    notifyListeners();
  }

  Future<void> updateIngredient(
      int id, String newText, String type, String quantity, String uom) async {
    final response = await Supabase.instance.client.from('ingredients').update({
      'name': newText,
      'quantity': quantity,
      'uom': uom,
    }).eq('id', id);
  }

  Future<void> deleteIngredient(int id, String type) async {
    final response = await Supabase.instance.client
        .from('ingredients')
        .delete()
        .eq('id', id);
  }

  Future<void> addLink(String linkName, String textFromUser, String serial,
      String type, String dish) async {
    final newLink = {
      'linkname': linkName,
      'link': textFromUser,
      'serial': serial,
      'type': type,
      'dish': dish,
    };

    final response =
        await Supabase.instance.client.from('links').insert(newLink);
    fetchLink(serial);
  }

  Future<List<Links>> fetchLink(String serial) async {
    final response = await Supabase.instance.client
        .from('links')
        .select()
        .eq('serial', serial);
    final data = List<Map<String, dynamic>>.from(response);

    currentLink.clear();
    currentLink.addAll(data.map((item) => Links(
          link: item['link'],
          linkName: item['linkname'],
          serial: item['serial'],
          type: item['type'],
          dish: item['dish'],
        )));

    notifyListeners();

    return currentLink.toList();
  }

  Future<void> updateLink(int id, String newText, String serial) async {
    final response = await Supabase.instance.client.from('links').update({
      'link': newText,
    }).eq('id', id);
  }

  Future<void> deleteLink(int id, String serial) async {
    final response =
        await Supabase.instance.client.from('links').delete().eq('id', id);
  }

  Future<List<Title>> fetchSingleTitle(String type) async {
    final response =
        await Supabase.instance.client.from('titles').select().eq('type', type);
    final data = List<Map<String, dynamic>>.from(response);

    currentTitle.clear();
    currentTitle.addAll(data.map((item) => Title(
          title: item['title'],
          type: item['type'],
        )));

    notifyListeners();

    return currentTitle.toList();
  }
}

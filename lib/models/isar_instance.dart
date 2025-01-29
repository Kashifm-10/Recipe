import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recipe/collections/homeTitle.dart';
import 'package:recipe/collections/ingredients.dart';
import 'package:recipe/collections/links.dart';
import 'package:recipe/collections/dishes.dart';
import 'package:recipe/collections/recipe.dart';

class IsarInstance {
  IsarInstance._privateConstructor();
  static final IsarInstance _instance = IsarInstance._privateConstructor();
  Isar? isar;

  factory IsarInstance() {
    return _instance;
  }

  init() async {
    var dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [DishSchema, 
      RecipeSchema, 
      IngredientsSchema, LinksSchema, TitleSchema],
      directory: dir.path,
      inspector: true,
    );
    return isar;
  }
}

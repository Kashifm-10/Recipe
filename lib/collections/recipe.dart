import 'package:isar/isar.dart';

part 'recipe.g.dart'; // required for code generation

@collection
class Recipe {
  Id id = Isar.autoIncrement;

  String? name;
  String? serial;
  String? type;
  String? dish;
  

  Recipe({
    this.name, this.serial, this.type, this.dish

  });

}

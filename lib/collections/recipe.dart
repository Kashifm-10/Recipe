import 'package:isar/isar.dart';

part 'recipe.g.dart'; // required for code generation

@collection
class Recipe {
  Id id = Isar.autoIncrement;

  String? name;
  String? type;
  String? dish;
  

  Recipe({
    this.name,this.type, this.dish

  });

}

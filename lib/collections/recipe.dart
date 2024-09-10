import 'package:isar/isar.dart';

part 'recipe.g.dart'; // required for code generation

@collection
class Recipe {
  Id id = Isar.autoIncrement;

  String? name;
  String? type;
  String? dish;
  String? link;

  Recipe({
    this.link,this.name,this.type, this.dish

  });

}

import 'package:isar/isar.dart';

part 'ingredients.g.dart'; // required for code generation

@collection
class Ingredients {
  Id id = Isar.autoIncrement;

  String? name;
  String? dish;
  Ingredients({
    required this.name,
    this.dish
  });
}

import 'package:isar/isar.dart';

part 'ingredients.g.dart'; // required for code generation

@collection
class Ingredients {
  Id id = Isar.autoIncrement;

  String? name;
  String? dish;
  String? quantity;
  String? uom;
  Ingredients({
    required this.name,
    this.dish, 
    this.quantity, 
    this.uom
  });
}

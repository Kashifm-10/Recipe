import 'package:isar/isar.dart';

part 'ingredients.g.dart'; // required for code generation

@collection
class Ingredients {
  Id id = Isar.autoIncrement;

  String? name;
  String? serial;
  String? dish;
  String? type;
  String? quantity;
  String? uom;
  Ingredients({
    required this.name,
    this.serial,
    this.dish, 
    this.type,
    this.quantity, 
    this.uom
  });
}

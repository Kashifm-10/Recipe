 
class Ingredients {
  late int id;

  String? name;
  String? serial;
  String? dish;
  String? type;
  String? quantity;
  String? uom;
  String? category;
  Ingredients({
    required this.name,
    this.serial,
    this.dish, 
    this.type,
    this.quantity, 
    this.uom,
    this.category
  });
}

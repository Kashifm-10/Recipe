import 'package:isar/isar.dart';

part 'links.g.dart'; // Ensure this matches the generated file name

@Collection()
class Links {
  Id id = Isar.autoIncrement;

  late String link;
  String? type;
  String? dish;

  Links({
    required this.link,
    this.type, this.dish
  });

}
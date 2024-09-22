import 'package:isar/isar.dart';

part 'links.g.dart'; // Ensure this matches the generated file name

@Collection()
class Links {
  Id id = Isar.autoIncrement;

  late String link;
  late String linkName;
  String? serial;
  String? type;
  String? dish;

  Links({
    required this.link,
    required this.linkName,
    this.serial,
    this.type, this.dish
  });

}
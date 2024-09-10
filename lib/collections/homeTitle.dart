import 'package:isar/isar.dart';

part 'homeTitle.g.dart'; // Ensure this matches the generated file name

@Collection()
class Title {
  Id id = Isar.autoIncrement;

  late String title;
  String? type;

  Title({
    required this.title,
    this.type, 
  });

}
import 'package:isar/isar.dart';

part 'names.g.dart'; // Ensure this matches the generated file name

@Collection()
class Dish {
  Id id = Isar.autoIncrement;

  late String name;
  String? serial;
  String? type;
  String? duration;
  String? category;
  String? time;
  String? date;

  Dish({
    required this.name, this.serial,
    this.type, this.duration, this.category, this.time,this.date
  });

}

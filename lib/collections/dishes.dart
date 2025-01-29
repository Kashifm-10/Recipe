import 'package:isar/isar.dart';

part 'dishes.g.dart'; // Ensure this matches the generated file name

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
  String? imageUrl;

  Dish({
    required this.name, this.serial,
    this.type, this.duration, this.category, this.time,this.date, this.imageUrl
  });

}

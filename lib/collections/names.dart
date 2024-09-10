import 'package:isar/isar.dart';

part 'names.g.dart'; // Ensure this matches the generated file name

@Collection()
class Dish {
  Id id = Isar.autoIncrement;

  late String name;
  String? type;
  String? duration;
  String? which;
  String? time;
  String? date;

  Dish({
    required this.name,
    this.type, this.duration, this.which, this.time,this.date
  });

}

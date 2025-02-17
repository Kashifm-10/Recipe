 
class Dish {
  late int id;

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



class Links {
  late int id;
  late String link;
  late String linkName;
  String? serial;
  String? type;
  String? dish;

  Links(
      {required this.id,
      required this.link,
      required this.linkName,
      this.serial,
      this.type,
      this.dish});
}

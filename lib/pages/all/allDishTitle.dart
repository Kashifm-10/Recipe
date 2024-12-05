import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:popover/popover.dart';
import 'package:recipe/collections/names.dart';
import 'package:recipe/pages/recipe.dart';
import 'package:recipe/notInUse/dish.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class allDishTile extends StatefulWidget {
  allDishTile({
    super.key,
    required this.dish,
    required this.duration,
    required this.category,
    required this.text,
    required this.type,
    this.onEditPressed,
    this.onDeletePressed,
  });
  String? type;
  String? dish;
  String? duration;
  String? category;
  final String text;
  final void Function()? onEditPressed;
  final void Function()? onDeletePressed;

  @override
  State<allDishTile> createState() => _allDishTileState();
}

class _allDishTileState extends State<allDishTile> {
  String title = '';

  @override
  void initState() {
    super.initState();
    fetchTitle();
  }

  Future<void> fetchTitle() async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('titles')
          .select('title')
          .eq('type', widget.type!)
          .single();

      if (response != null && response['title'] != null) {
        setState(() {
          title = response['title'];
        });
        print('Fetched title: $title');
      }
    } catch (error) {
      print('Error fetching title: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.1,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 10,
              top: 10,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: Colors.white.withOpacity(0.0),
                child: widget.category == "1"
                    ? Icon(Icons.circle_rounded, color: Colors.red, size: 15)
                    : Icon(Icons.circle_rounded, color: Colors.green, size: 15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.text,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 5),
                          Text(
                            widget.duration != null
                                ? (() {
                                    double duration =
                                        double.tryParse(widget.duration!) ??
                                            0.0;
                                    int hours = duration.toInt();
                                    int minutes =
                                        ((duration - hours) * 60).toInt();

                                    if (hours > 0 && minutes > 0) {
                                      return '$hours hour ${minutes} minutes';
                                    } else if (hours > 0) {
                                      return '$hours hour';
                                    } else if (minutes > 0) {
                                      return '$minutes minutes';
                                    } else {
                                      return '0 minutes';
                                    }
                                  }())
                                : 'Invalid duration',
                            style: TextStyle(
                              color: Colors.grey.shade900,
                              fontSize: 16,
                            ),
                          )
                        ],
                      ),
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

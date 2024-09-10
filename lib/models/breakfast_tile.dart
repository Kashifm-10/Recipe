import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:recipe/collections/names.dart';
import 'package:recipe/pages/recipe.dart';
import 'package:recipe/models/noteSettings.dart';
import 'package:recipe/models/dish.dart';

class DishTile extends StatelessWidget {
  DishTile({
    super.key,
    required this.dish,
    required this.duration,
    required this.which,
    required this.text,
    required this.type,
    this.onEditPressed,
    this.onDeletePressed,
  });
  String? type;
  String? dish;
  String? duration;
  String? which;
  final String text;
  final void Function()? onEditPressed;
  final void Function()? onDeletePressed;



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        height: 150,
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
                child: which == "1"
                    ? Icon(Icons.circle_rounded, color: Colors.red, size: 15)
                    : Icon(Icons.circle_rounded, color: Colors.green,size: 15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    text,
                    style:  TextStyle(
                      color:  Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom:  4.0),
                        child: Icon(Icons.timer, color: Colors.grey.shade400),
                      ),
                      SizedBox(width: 5),
                      Text(
                        '$duration hours',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
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



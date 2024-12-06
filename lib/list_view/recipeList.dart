import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:recipe/pages/recipePage.dart';

class RecipeList extends StatelessWidget {
  RecipeList({
    super.key,
    required this.dish,
    required this.text,
    this.onEditPressed,
    this.onDeletePressed,
  });

  final String? dish;
  final String text;
  final void Function()? onEditPressed;
  final void Function()? onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.width > 600 ? 8 : 0,
          horizontal: MediaQuery.of(context).size.width > 600
              ? 20
              : 15), // Padding around the list item
      leading: Icon(Icons.circle,
          size: 7,
          color:
              Theme.of(context).colorScheme.primary), // Small circle as a point
      title: GestureDetector(
        onLongPress: () {
          onEditPressed!();
        },
        child: Text(
          text,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width > 600
                ? 25
                : MediaQuery.of(context).size.width * 0.04,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          textAlign:
              TextAlign.left, // Justified text alignment for cleaner look
        ),
      ),
      // Optional actions at the end of each item, if needed (e.g., delete, edit)
    );
  }
}

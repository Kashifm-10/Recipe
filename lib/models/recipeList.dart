import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:recipe/pages/recipe.dart';
import 'package:recipe/models/noteSettings.dart';

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
      contentPadding: const EdgeInsets.symmetric(
          vertical: 8, horizontal: 20), // Padding around the list item
      leading: Icon(Icons.circle,
          size: 7,
          color:
              Theme.of(context).colorScheme.primary), // Small circle as a point
      title: GestureDetector(
        onLongPress: () => showPopover(
          width: 100,
          height: 100,
          backgroundColor: Theme.of(context).colorScheme.surface,
          context: context,
          bodyBuilder: (context) => Notesettings(
            onEditTap: onEditPressed,
            onDeleteTap: onDeletePressed,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 25,
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

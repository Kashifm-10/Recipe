import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:recipe/pages/recipe.dart';
import 'package:recipe/models/noteSettings.dart';

class recipeList extends StatelessWidget {
  recipeList(
      {super.key,
      required this.dish,
      required this.type,
      required this.text,
      this.onEditPressed,
      this.onDeletePressed});
  String? dish;
  String? type;
  final String text;
  final void Function()? onEditPressed;
  final void Function()? onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      /* decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.only(top: 10, left: 25, right: 25), */
      child: ListTile(
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
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(
            text,
            textAlign: TextAlign.left,
            
            style: TextStyle(color: const Color.fromARGB(255, 20, 17, 17), fontSize: 20),
          ),
        ),
      )

          /* trailing: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => showPopover(
                width: 100,
                height: 100,
                backgroundColor: Theme.of(context).colorScheme.surface,
                context: context,
                bodyBuilder: (context) => Notesettings(
                    onEditTap: onEditPressed, onDeleteTap: onDeletePressed)),
          ),
        ), */
          // trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          //   IconButton(onPressed: onEditPressed, icon: const Icon(Icons.edit)),
          //   IconButton(onPressed: onDeletePressed, icon: const Icon(Icons.delete))
          // ]),
          ),
    );
  }
}

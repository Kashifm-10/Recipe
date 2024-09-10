import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:recipe/pages/recipe.dart';
import 'package:recipe/models/noteSettings.dart';

class ingredientList extends StatelessWidget {
   ingredientList(
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
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ListTile(
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
  child: Row(
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Text(
          '• ',
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ),
      Expanded(
        child: Text(
          text,
          textAlign: TextAlign.left,
          style: TextStyle(color: const Color.fromARGB(255, 20, 17, 17), fontSize: 20 ),
        ),
      ),
    ],
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
                onEditTap: onEditPressed,
                onDeleteTap: onDeletePressed,
              ),
            ),
          ),
        ), */
      ),
    ],
  ),
);

  }
}
